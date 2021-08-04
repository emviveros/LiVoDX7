# META NAME Kiosk
# META DESCRIPTION all windows in fullscreen mode
# META DESCRIPTION main window invisible
# META DESCRIPTION no keybindings

# META AUTHOR IOhannes m zmölnig <zmoelnig@iem.at>


package require Tcl 8.5
package require Tk
package require pdwindow 0.1

namespace eval ::kiosk:: {
    variable ::kiosk::config
    variable ::kiosk::processed
}
set ::kiosk::mangledtitles() "Pd"

## default values
set ::kiosk::config(KioskNewWindow) False
set ::kiosk::config(ShowMenu) True
set ::kiosk::config(ShowMenuMain) True
set ::kiosk::config(FullScreen) False
set ::kiosk::config(HideMain) False
set ::kiosk::config(WindowTitle) ""
set ::kiosk::config(WindowDynamicTitle) ""
set ::kiosk::config(WindowTitleMain) ""
set ::kiosk::config(HidePopup) False
set ::kiosk::config(ScrollBars) True
set ::kiosk::config(QuitOnClose) False
set ::kiosk::config(PreventClose) False
set ::kiosk::config(Bindings) True
set ::kiosk::config(QuitBinding) True
set ::kiosk::config(GeometryMain) ""
set ::kiosk::processed(.pdwindow) True



proc ::kiosk::readconfig {{fname kiosk.cfg}} {
  set orgname $fname
  if {[file exists $fname]} {
    set fp [open $fname r]
  } else {
      set fname [file join $::current_plugin_loadpath $fname]
      if {[file exists $fname]} {
          set fp [open $fname r]
      } else {
          puts "kiosk-configuration not found: $orgname"
          return False
      }
  }
  while {![eof $fp]} {
      set data [gets $fp]
      if { [string is list $data ] } {
          if { [llength $data ] > 1 } {
              set ::kiosk::config([lindex $data 0]) [lindex $data 1]
          }
      }
  }


 return True
}

## KIOSkify a window
proc ::kiosk::unmakekiosk {mywin} {
    if { [info exists ::kiosk::processed($mywin)] } {
        set ::kiosk::processed($mywin) False
    }
}
proc ::kiosk::makekiosk {mywin} {
    ## refuse to kioskify the main Pd window
    if { ! [info exists ::kiosk::processed($mywin)] } {
        set ::kiosk::processed($mywin) False
    }
    if { $::kiosk::processed($mywin) } { return;  }
    set ::kiosk::processed($mywin) True

#remove menu
    if { $::kiosk::config(ShowMenu) } { } {
        $mywin configure -menu .kioskmenu;
    }

# make fullscreen
    if { $::kiosk::config(FullScreen) } {
    	wm attributes $mywin -fullscreen 1
    }

# set the title of the window
    # (makes mostly sense in non-fullscren...)
    if [info exists ::kiosk::mangledtitles($mywin)] { } {
        set ::kiosk::mangledtitles($mywin) [::kiosk::titlemangler [wm title $mywin]]
    }
    wm title $mywin $::kiosk::mangledtitles($mywin)

# close pd if the window is closed (or no close at all)
    if { $::kiosk::config(PreventClose) } {
        # prevent WindowClose using Alt-F4 or clicking on the "x"
        wm protocol $mywin WM_DELETE_WINDOW ";"
    } {
        # if we do allow closing of windows, we might want to Quit as well
        if { $::kiosk::config(QuitOnClose) } {
            bind $mywin <Destroy> "pdsend \"pd quit\""
        }
    }

    set mycnv [tkcanvas_name $mywin ]

# remove all special key/mouse bindings from the window
    if { $::kiosk::config(QuitBinding) } { } {
#         bind $mycnv <Control-Key-w> {}
#         bind $mycnv <Control-Shift-Key-W> {}
#         bind all <Control-Key-w> {}
#         bind all <Control-Shift-Key-W> {}

        bind $mycnv <Control-Key-q> {}
        bind $mycnv <Control-Shift-Key-Q> {}
        bind all <Control-Key-q> {}
        bind all <Control-Shift-Key-Q> {}
    }
# remove all special key/mouse bindings from the window
    if { $::kiosk::config(Bindings) } { } {
        bindtags $mywin ""
        bindtags $mycnv "$mycnv"
# rebind ordinary keypress events
        bind $mycnv <KeyPress>         {::pd_bindings::sendkey %W 1 %K %A 0}
        bind $mycnv <KeyRelease>       {::pd_bindings::sendkey %W 0 %K %A 0}
        bind $mycnv <Shift-KeyPress>   {::pd_bindings::sendkey %W 1 %K %A 1}
        bind $mycnv <Shift-KeyRelease> {::pd_bindings::sendkey %W 0 %K %A 1}
    }
}


######################################
proc ::kiosk::init {version} {
# this is just an empty menu
catch {menu .kioskmenu}

## read the default configuration file "kiosk.cfg"
if { [info exists ::env(PD_KIOSK_CONFIG) ] } {
  ::kiosk::readconfig $::env(PD_KIOSK_CONFIG)
} {
  ::kiosk::readconfig
}


###### do some global KIOSK-settings

## set the geometry of the Pd window
if { $::kiosk::config(GeometryMain) != "" } {
    wm geometry .pdwindow =$::kiosk::config(GeometryMain)
}
## hide the Pd window
if { $::kiosk::config(HideMain) } {
    set ::stderr 1
    wm state .pdwindow withdraw
}
## hide the menu on the Pd window
if { $::kiosk::config(ShowMenuMain) } { } {
    .pdwindow configure -menu .kioskmenu
}
## override the window title of the Pd window
if { $::kiosk::config(WindowTitleMain) != "" } {
    wm title .pdwindow $::kiosk::config(WindowTitleMain)
}
proc ::kiosk::titlemangler {s}  {return $s}
if { $::kiosk::config(WindowDynamicTitle) != "" } {
    proc ::kiosk::titlemangler [lindex $::kiosk::config(WindowDynamicTitle) 0] [lindex $::kiosk::config(WindowDynamicTitle) 1]
} {
    if { $::kiosk::config(WindowTitle) != "" } {
        proc ::kiosk::titlemangler {s}  "return $::kiosk::config(WindowTitle)"
    }
}

## don't show popup menu on right-click
if { $::kiosk::config(HidePopup) }  {
 proc ::pdtk_canvas::pdtk_canvas_popup {mytoplevel xcanvas ycanvas hasproperties hasopen} { }
}

if { $::kiosk::config(ScrollBars) } { } {
    proc ::pdtk_canvas::pdtk_canvas_getscroll {tkcanvas} { }
}

# do the KIOSK-setting per existing window (those windows loaded at startup)
foreach kioskwin [array names ::loaded] {
    ::kiosk::makekiosk $kioskwin
}

# do the KIOSKification for newly created windows as well
if { $::kiosk::config(KioskNewWindow) }  {
 ## not the most elegant way: KIOSKifying each window as some of its properties change...
 bind PatchWindow <Configure> "+::kiosk::makekiosk %W"
 bind PatchWindow <Destroy> "+::kiosk::unmakekiosk %W"

}

pdtk_post "loaded: kiosk-plugin ${version}\n"
}

::kiosk::init {}
