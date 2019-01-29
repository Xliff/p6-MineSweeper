use v6.c;

use MineSweeper::NewGameWin;
use MineSweeper::Grid
use MineSweeper::Logic;

unit package MineSweeper;

sub MAIN is export {
  my $newgame = MineSweeper::NewGameWin;

  # Endless loop. Leave it to the events.
  repeat {
    my $response = $newgame.run;
    $a.exit if $response == GTK_RESPONSE_CANCEL;

    my $logic = MineSweeper::Logic.new($!width, $!height, $!mine-ratio);
    my $grid = MineSweeper::Grid.new($logic);

    $grid.show_all;
    await $grid.game-finished;

    FINALLY { $grid.hide with $grid }
    CATCH {
      when X::MineSweeper::GameWon   |
           X::MineSweeper::GameLost  {
        GTK::Dialog::Message.new($grid, .message).run;

        $b<NewGameWin>.show_all;
      }

      default {
        $grid.hide;
        warn .message;
        Backtrace.new.Str.say;
        $a.exit;
      }
    }
  }
}
