import curses
import platform

#license info screen starts here
#license_info = "ncurses ui template\n(c) 2025 nikolai august bostrup strunge  / iateacatandawhalen on github\n(see below for a link to the github repo for the template\nLicensed under the gun gpl\ngithub repo?: yet to be created (link will be added once i create the repo)\n..."
h1 = "ncurses ui template"
h2="(c) 2025 nikolai august bostrup strunge / iateacatandawhalen on github (see below for a link to the github repo for this template)"
h3 = " (github repo not created yet (will update once created)"
h4 = "licensed under the gnu gpl (link to the terms of the gnu gpl license coming soon..."
        
#license info screen ends here















#class for fetching the *PRETTY NAME* variable hereby known as the 'Distro' class starts here
class Distro:
    @staticmethod
    def get_name():
        # get pretty name from /etc/os-release (if file is not available return fallback name
        try:
            with open("/etc/os-release") as f:
                for line in f:
                    if line.startswith("PRETTY_NAME="):
                        return line.strip().split("=", 1)[1].strip('"')
        except FileNotFoundError:
            pass
        return platform.system() # fallback name
#Distro class ends here ;-)#

#title bar section starts here
def titlebar(stdscr, title):
    h, w = stdscr.getmaxyx()
    
    stdscr.attron(curses.color_pair(1))
    stdscr.addstr(0, 0, " " * (w - 1))
    stdscr.attroff(curses.color_pair(1))

    x = max(0, (w // 2) - (len(title) // 2))
    stdscr.attron(curses.color_pair(2))
    stdscr.addstr(0, x, title)
    stdscr.attroff(curses.color_pair(2))
#title bar section ends here

#main section starts here
def main(stdscr):
    curses.curs_set(0)
    curses.start_color()
    curses.init_pair(1, curses.COLOR_WHITE, curses.COLOR_BLUE)
    curses.init_pair(2, curses.COLOR_RED, curses.COLOR_BLUE)

    distro_name = Distro.get_name()
#main section ends here fyi

#program ''while true'' loop starts here
    while True:
        stdscr.clear()
        titlebar(stdscr, distro_name)
        stdscr.addstr(2, 2, "main content space")
        stdscr.refresh()

        key = stdscr.getch()
        if key == ord('q'):
            break
#        elif key == ord('h'):
#            stdscr.clear
#            stdscr.addstr(3, 3, h1)
#            stdscr.addstr(4, 4, h2)
#            stdscr.addstr(5, 5, h3)
#            stdscr.refresh()
#            break

#        elif key == ord('b'):
#            stdscr.clear()
 #           main(stdscr)
  #          stdscr.refresh
   #         break

            
        
curses.wrapper(main)
#program ''while true'' loop ends here

