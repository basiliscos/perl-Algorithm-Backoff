package Algorithm::Backoff;
# ABSTRACT: generates exponential backoff until some limit

use strict;
use warnings;

=head1 VERSION

Version 0.01

=cut

our $VERSION = 0.01;

=head1 STATUS

=begin HTML

<p>
    <a href="https://travis-ci.org/binary-com/perl-Algorithm-Backoff"><img src="https://travis-ci.org/binary-com/perl-Algorithm-Backoff.svg" /></a>
</p>

=end HTML

=head1 SYNOPSIS

    use Algorithm::Backoff;

    my $backoff = Algorithm::Backoff->new(
        min   => 0.1,
        max   => 5,
    );

    my $some_service = Some::Service->new;

    while (1) {
        my $delay = $backoff->next_value;
        sleep($delay);
        my $result = eval { $some_service->run; 1 };
        if ($result) {
            # seems all fine with service
            $backoff->reset_value;
        } else {
            # Ooops! We failed
            warn "Service failed: $@" if @$;
            warn "Alarm! Too many service  failures!"
                if $backoff->limit_reached;

        }
    }

In case of C<some_service> failures, this snipplet will sleep
0, 0.1, 0.2, 0.4 ... 3.2, seconds before next attempt to launch
C<some_service> again. If it continue to fail it the sleep delay
before next attempts will be C<5>, and it will emit additional
warnings.

=head1 DESCRIPTION

The backoff algorihm generates sequence of numbers, each one
is just doubled previous value until it hits maximum. The first
value is by convension zero.

This numbers are useful, for example, when some service is
choking under load (or restarting), and instead of endlessly
poll it like

    while(1) {
        try {
            $service->connect;
            $service->get_something;
        };
    }

The algorim allows to poll it in more polite manner, i.e.
with increasing delay with each next attempt.

=head1 STATIC METHODS

=head2 new($class, min => $min_value, max => $max_value)

Creates new backoff instance which will operate in
the defined C<$min_value> .. C<$max_value> range.

Backoff object remembers it's state between invocations.

=cut

sub new {
    my ($class, @given) = @_;
    my $message = "Incorrect construction invocation. Correct is: ->new(min => value, max => value)";
    die($message) if scalar(@given) % 2;
    my %args = @given;
    my $min  = $args{min} // die($message);
    my $max  = $args{max} // die($message);
    return bless {
        min           => $min,
        max           => $max,
        attempts      => -1,
        limit_reached => 0
    }, $class;
}

=head1 METHODS

=head2 next_value

Returns next backoff value. It can be used for C<sleep>, if the value
given range is in seconds.

=cut

sub next_value {
    my $self          = shift;
    my $attempts      = $self->{attempts};
    my $value         = $attempts < 0 ? 0 : $self->{min} * (2**$attempts);
    my $max           = $self->{max};
    my $exceeds_limit = $value > $max;
    # prevent overflow
    $self->{attempts}++ unless $exceeds_limit;
    $self->{limit_reached} = $exceeds_limit;

    return !$exceeds_limit ? $value : $max;
}

=head2 limit_reached

Returns C<true> if limit has been reached with the last C<next_value>
invocation. Intended to attract attention of the responsible personnel,
i.e. emit warning, send SMS etc.

=cut

sub limit_reached {
    return shift->{limit_reached};
}

=head2 reset_value

Resets internal state. The following C<next_value> invocation will
give 0.

=cut

sub reset_value {
    my $self = shift;
    $self->{attempts} = -1;
    $self->{attempts} = 0;
}

=head1 AUTHOR

Binary.com, C<< <support at binary.com> >>

=head1 BUGS

Please report any bugs or feature requests to https://github.com/binary-com/perl-Algorithm-Backoff/issues.

=cut

=head1 LICENSE AND COPYRIGHT

Copyright 2017 Binary.com.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

1;
