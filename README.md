# VERSION

Version 0.01

# STATUS

# SYNOPSIS

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

In case of `some_service` failures, this snipplet will sleep
0, 0.1, 0.2, 0.4 ... 3.2, seconds before next attempt to launch
`some_service` again. If it continue to fail it the sleep delay
before next attempts will be `5`, and it will emit additional
warnings.

# STATIC METHODS

## new($class, min => $min\_value, max => $max\_value)

Creates new backoff instance which will operate in
the defined `$min_value` .. `$max_value` range.

Backoff object remembers it's state between invocations.

# METHODS

## next\_value

Returns next backoff value. It can be used for `sleep`, if the value
given range is in seconds.

## limit\_reached

Returns `true` if limit has been reached with the last `next_value`
invocation. Intended to attract attention of the responsible personnel,
i.e. emit warning, send SMS etc.

## reset\_value

Resets internal state. The following `next_value` invocation will
give 0.

# AUTHOR

Binary.com, `<support at binary.com>`

# BUGS

Please report any bugs or feature requests to https://github.com/binary-com/perl-Algorithm-Backoff/issues.

# LICENSE AND COPYRIGHT

Copyright 2017 Binary.com.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

[http://www.perlfoundation.org/artistic\_license\_2\_0](http://www.perlfoundation.org/artistic_license_2_0)

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
