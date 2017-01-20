use strict;
use warnings;

use Test::More;
use Algorithm::Backoff;

my $rounding_error = 0.000001;

subtest "use intervals" => sub {
    my $backoff = Algorithm::Backoff->new(
        min   => 0.1,
        max   => 5,
    );

    is $backoff->next_value, 0;
    ok !$backoff->limit_reached, "no need to panic";
    ok abs($backoff->next_value - 0.1) < $rounding_error;
    ok !$backoff->limit_reached;
    ok abs($backoff->next_value - 0.2) < $rounding_error;
    ok !$backoff->limit_reached;
    ok abs($backoff->next_value - 0.4) < $rounding_error;
    ok !$backoff->limit_reached;
    ok abs($backoff->next_value - 0.8) < $rounding_error;
    ok !$backoff->limit_reached;
    ok abs($backoff->next_value - 1.6) < $rounding_error;
    ok !$backoff->limit_reached;
    ok abs($backoff->next_value - 3.2) < $rounding_error;
    ok !$backoff->limit_reached;
    ok abs($backoff->next_value - 5) < $rounding_error;
    ok $backoff->limit_reached, "Alarm!";
    ok abs($backoff->next_value - 5) < $rounding_error;
    ok $backoff->limit_reached, "Alarm!";
};

done_testing;
