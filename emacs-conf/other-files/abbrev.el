;;-*-coding: emacs-mule;-*-
(define-abbrev-table 'Buffer-menu-mode-abbrev-table '())

(define-abbrev-table 'calendar-mode-abbrev-table '())

(define-abbrev-table 'comint-mode-abbrev-table '())

(define-abbrev-table 'completion-list-mode-abbrev-table '())

(define-abbrev-table 'cperl-mode-abbrev-table
  '(
    ("usedump" "use Data::Dumper qw(Dumper);" pde-abbv-no-blank 0)
    ("useenc" "use Encode qw(encode decode from_to);" pde-abbv-no-blank 0)
    ("usegtk" "use Gtk2 '-init';
use Glib qw(TRUE FALSE);

my $window = Gtk2::Window->new('toplevel');
$window->signal_connect('delete_event' => sub { Gtk2->main_quit; });" pde-abbv-no-blank 0)
    ("useopt" "use Getopt::Long;
GetOptions();" pde-abbv-no-blank 0)
   ))

(define-abbrev-table 'diary-fancy-display-mode-abbrev-table '())

(define-abbrev-table 'diary-mode-abbrev-table '())

(define-abbrev-table 'emacs-lisp-mode-abbrev-table '())

(define-abbrev-table 'fundamental-mode-abbrev-table '())

(define-abbrev-table 'global-abbrev-table '())

(define-abbrev-table 'lisp-mode-abbrev-table '())

(define-abbrev-table 'org-mode-abbrev-table '())

(define-abbrev-table 'outline-mode-abbrev-table '())

(define-abbrev-table 'special-mode-abbrev-table '())

(define-abbrev-table 'text-mode-abbrev-table '())

