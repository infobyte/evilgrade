package isrcore::Stanford::DNS;

use strict;
use vars qw(@ISA @EXPORT %Op2A %Err2A %Type2A %Class2A);

use Exporter;
@ISA = qw(Exporter);

@EXPORT = qw(

  QR_MASK  OP_MASK  AA_MASK  TC_MASK  RD_MASK  RA_MASK  Z_MASK  RCODE_MASK
  QR_SHIFT OP_SHIFT AA_SHIFT TC_SHIFT RD_SHIFT RA_SHIFT Z_SHIFT RCODE_SHIFT

  QPTR PACKETSZ MAXDNAME MAXCDNAME MAXLABEL HEADERLEN DEFAULTPORT

  QUERY IQUERY STATUS

  NOERROR FORMERR SERVFAIL NXDOMAIN NOTIMP REFUSED

  T_INVALID T_A T_NS T_MD T_MF T_CNAME T_SOA T_MB T_MG T_MR T_NULL T_WKS
  T_PTR T_HINFO T_MINFO T_MX T_TXT T_RP T_AFSDB T_X25 T_ISDN T_RT T_NSAP
  T_NSAP_PTR T_SIG T_KEY T_PX T_GPOS T_AAAA T_LOC T_NXT T_EID T_NIMLOC
  T_SRV T_ATMA T_NAPTR T_KX T_CERT T_A6 T_DNAME T_SINK T_OPT T_TKEY T_TSIG
  T_IXFR T_AXFR T_MAILB T_MAILA T_ANY T_ZXFR

  C_IN C_CHAOS C_HS C_ANY

  %Op2A %Err2A %Type2A %Class2A

  rr_A rr_CNAME rr_NS rr_PTR rr_NULL rr_MX rr_SOA rr_TXT rr_HINFO rr_RP
  rr_WKS rr_LOC rr_LOC_raw rr_SRV

  dns_answer dns_simple_dname dn_expand

);

# bit masks to get values

sub QR_MASK()    { 0x8000 }  # query(0) or response(1) bit
sub OP_MASK()    { 0x7800 }  # query type (4 bits)
sub AA_MASK()    { 0x0400 }  # authoritative answer bit
sub TC_MASK()    { 0x0200 }  # truncation bit
sub RD_MASK()    { 0x0100 }  # recursion desired bit
sub RA_MASK()    { 0x0080 }  # recursion available bit
sub Z_MASK()     { 0x0070 }  # 3 reserved bits (must be zero)
sub RCODE_MASK() { 0x000f }  # response code (4 bits)

# number of bits to shift left/right in 16 bit field

sub QR_SHIFT()    { 15 }
sub OP_SHIFT()    { 11 }
sub AA_SHIFT()    { 10 }
sub TC_SHIFT()    {  9 }
sub RD_SHIFT()    {  8 }
sub RA_SHIFT()    {  7 }
sub Z_SHIFT()     {  4 }
sub RCODE_SHIFT() {  0 }

# misc constants

sub QPTR()        { pack('n', 0xc00c) }  # PTR to original question in the packet

sub PACKETSZ()    {  512 }
sub MAXDNAME()    { 1025 }
sub MAXCDNAME()   {  255 }
sub MAXLABEL()    {   63 }

sub HEADERLEN()   {   12 }

sub DEFAULTPORT() {   53 }

# opcodes

sub QUERY()  { 0 }
sub IQUERY() { 1 }
sub STATUS() { 2 }

%Op2A = (
  QUERY()  => 'QUERY',
  IQUERY() => 'IQUERY',
  STATUS() => 'STATUS',
);

# errors

sub NOERROR()   { 0 }  # success!
sub FORMERR()   { 1 }  # unable to interpret the query
sub SERVFAIL()  { 2 }  # problem with the name server
sub NXDOMAIN()  { 3 }  # the domain name does not exist (only used with AA!)
sub NOTIMP()    { 4 }  # not implemtented
sub REFUSED()   { 5 }  # query disallowed by policy

%Err2A = (
  NOERROR()  => 'NOERROR',
  FORMERR()  => 'FORMERR',
  SERVFAIL() => 'SERVFAIL',
  NXDOMAIN() => 'NXDOMAIN',
  NOTIMP()   => 'NOTIMP',
  REFUSED()  => 'REFUSED',
);

# types

sub T_INVALID()  {   0 }
sub T_A()        {   1 }
sub T_NS()       {   2 }
sub T_MD()       {   3 }
sub T_MF()       {   4 }
sub T_CNAME()    {   5 }
sub T_SOA()      {   6 }
sub T_MB()       {   7 }
sub T_MG()       {   8 }
sub T_MR()       {   9 }
sub T_NULL()     {  10 }
sub T_WKS()      {  11 }
sub T_PTR()      {  12 }
sub T_HINFO()    {  13 }
sub T_MINFO()    {  14 }
sub T_MX()       {  15 }
sub T_TXT()      {  16 }
sub T_RP()       {  17 }
sub T_AFSDB()    {  18 }
sub T_X25()      {  19 }
sub T_ISDN()     {  20 }
sub T_RT()       {  21 }
sub T_NSAP()     {  22 }
sub T_NSAP_PTR() {  23 }
sub T_SIG()      {  24 }
sub T_KEY()      {  25 }
sub T_PX()       {  26 }
sub T_GPOS()     {  27 }
sub T_AAAA()     {  28 }
sub T_LOC()      {  29 }
sub T_NXT()      {  30 }
sub T_EID()      {  31 }
sub T_NIMLOC()   {  32 }
sub T_SRV()      {  33 }
sub T_ATMA()     {  34 }
sub T_NAPTR()    {  35 }
sub T_KX()       {  36 }
sub T_CERT()     {  37 }
sub T_A6()       {  38 }
sub T_DNAME()    {  39 }
sub T_SINK()     {  40 }
sub T_OPT()      {  41 }
sub T_TKEY()     { 249 }
sub T_TSIG()     { 250 }
sub T_IXFR()     { 251 }
sub T_AXFR()     { 252 }
sub T_MAILB()    { 253 }
sub T_MAILA()    { 254 }
sub T_ANY()      { 255 }
sub T_ZXFR()     { 256 }

%Type2A = (
  T_INVALID()  => 'INVALID',
  T_A()        => 'A',
  T_NS()       => 'NS',
  T_MD()       => 'MD',
  T_MF()       => 'MF',
  T_CNAME()    => 'CNAME',
  T_SOA()      => 'SOA',
  T_MB()       => 'MB',
  T_MG()       => 'MG',
  T_MR()       => 'MR',
  T_NULL()     => 'NULL',
  T_WKS()      => 'WKS',
  T_PTR()      => 'PTR',
  T_HINFO()    => 'HINFO',
  T_MINFO()    => 'MINFO',
  T_MX()       => 'MX',
  T_TXT()      => 'TXT',
  T_RP()       => 'RP',
  T_AFSDB()    => 'AFSDB',
  T_X25()      => 'X25',
  T_ISDN()     => 'ISDN',
  T_RT()       => 'RT',
  T_NSAP()     => 'NSAP',
  T_NSAP_PTR() => 'NSAP_PTR',
  T_SIG()      => 'SIG',
  T_KEY()      => 'KEY',
  T_PX()       => 'PX',
  T_GPOS()     => 'GPOS',
  T_AAAA()     => 'AAAA',
  T_LOC()      => 'LOC',
  T_NXT()      => 'NXT',
  T_EID()      => 'EID',
  T_NIMLOC()   => 'NIMLOC',
  T_SRV()      => 'SRV',
  T_ATMA()     => 'ATMA',
  T_NAPTR()    => 'NAPTR',
  T_KX()       => 'KX',
  T_CERT()     => 'CERT',
  T_A6()       => 'A6',
  T_DNAME()    => 'DNAME',
  T_SINK()     => 'SINK',
  T_OPT()      => 'OPT',
  T_TKEY()     => 'TKEY',
  T_TSIG()     => 'TSIG',
  T_IXFR()     => 'IXFR',
  T_AXFR()     => 'AXFR',
  T_MAILB()    => 'MAILB',
  T_MAILA()    => 'MAILA',
  T_ANY()      => 'ANY',
  T_ZXFR()     => 'ZXFR'
);

# classes

sub C_IN()    {   1 }
sub C_CHAOS() {   3 }
sub C_HS()    {   4 }
sub C_ANY()   { 255 }

%Class2A = (
  C_IN()    => 'IN',
  C_CHAOS() => 'CH',
  C_HS()    => 'HS',
  C_ANY()   => 'ANY'
);

# resource record encoding

sub dns_answer {
    my ($name, $type, $class, $ttl, $rdata) = @_;
    return $name . pack('nnNna*', $type, $class, $ttl, length $rdata, $rdata);
}

sub rr_A     { return pack('N', shift)        }
sub rr_CNAME { return dns_simple_dname(shift) }
sub rr_NS    { return dns_simple_dname(shift) }
sub rr_PTR   { return dns_simple_dname(shift) }
sub rr_NULL  { return shift                   }

sub rr_MX {
    my ($pref, $exchange) = @_;
    return pack('n', $pref) . dns_simple_dname($exchange);
}

sub rr_SOA {
    my ($mname, $rname, $serial, $refresh, $retry, $expire, $minimum) = @_;
    return dns_simple_dname($mname) . dns_simple_dname($rname)
      . pack('NNNNN', $serial, $refresh, $retry, $expire, $minimum);
}

sub rr_TXT {
    my $text = shift;
    my $res = '';
    for (my $i = 0; $i < length $text; $i += 255) {
        my $t = substr($text, $i, 255);
        $res .= pack('Ca*', length $t, $t);
    }
    $res;
}

sub rr_HINFO {
    my ($cpu, $os) = @_;
    return pack('Ca*Ca*', length $cpu, $cpu, length $os, $os);
}

sub rr_RP {
    my ($mbox, $txt) = @_;
    $txt ||= '.';
    return dns_simple_dname($mbox) . dns_simple_dname($txt);
}

sub rr_WKS {
    my ($address, $protocol, @portlist) = @_;
    my $vec = '';
    vec($vec, $_, 1) = 1 foreach @portlist;
    return pack('NC', $address, $protocol) . $vec;
}

# XXX lengths should be encoded by this function, not by the user! (RFC 1876)
sub rr_LOC { die 'rr_LOC is not implemented. Please use rr_LOC_raw'; }
sub rr_LOC_raw {
    my ($size, $horizpre, $vertpre, $lat, $long, $alt) = @_;
    return pack('xC3N3', $size, $horizpre, $vertpre, $lat, $long, $alt);
}

sub rr_SRV {
    my ($priority, $weight, $port, $target) = @_;
    return pack('n3', $priority, $weight, $port) . dns_simple_dname($target);
}

sub dns_simple_dname {
    my $result;
    $result .= pack('Ca*', length $_, $_) foreach split(/\./, shift);
    return $result . "\0";
}

# expand the domain name stored at $offset of $$msg
# Returns the domain name and the offset of the next location in the packet.
# $msg is a reference even if it's not modified. This saves some byte copying.

sub dn_expand {
    my ($msg, $offset) = @_;

    my $cp       = $offset;
    my $result   = '';
    my $comp_len = -1;
    my $checked  = 0;

    while (my $n = ord(substr($$msg, $cp++, 1))) {
        if (($n & 0xc0) == 0) {
            $checked += $n + 1;
            $result .= '.' if $result;
            while (--$n >= 0) {
                my $c = substr($$msg, $cp++, 1);
                $result .= ($c ne '.') ? $c : '\\';
            }
        } elsif (($n & 0xc0) == 0xc0) {  # pointer, follow it
            $checked += 2;
            return (undef, undef) if $checked >= length $$msg;
            $comp_len = $cp - $offset if $comp_len == -1;
            $cp = ($n & 0x3f) << 8 + ord(substr($$msg, $cp, 1));
        } else {  # unknown (or extended) type
            return (undef, undef);
        }
    }
    $comp_len = $cp - $offset if $comp_len == -1;
    return ($result, $offset + $comp_len);
}


1;
__END__

=head1 NAME

isrcore::Stanford::DNS - DNS Name Functions and Constants

=head1 SYNOPSIS

  use isrcore::Stanford::DNS;

  $answer = dns_answer(QPTR, T_TXT, C_IN, 60, rr_TXT($text));

=head1 DESCRIPTION

B<isrcore::Stanford::DNS> defines DNS name functions and constants.  The
B<dns_answer> function is perhaps the most important function.  It is
used to create DNS answers returned by B<isrcore::Stanford::DNSserver> dynamic
request handlers.  The B<rr_*> family of functions are used to format
the data needed by B<dns_answer>.

=head1 FUNCTIONS

B<dns_answer> I<$qptr, $type, $class, $ttl, $rdata>

Returns a DNS answer of type I<$type> and class I<$class> with TTL
I<$ttl> using the input resource record data I<$rdata>.

B<rr_*> I<$data>

B<isrcore::Stanford::DNS> defines resource record functions for most DNS record
types.  The most common types are listed below.  Please refer to the
source for the rest.

=over

=item * B<rr_A> I<$ip_address>

Format an address record.

=item * B<rr_CNAME> I<$name>

Format a CNAME (alias) address record.

=item * B<rr_NS> I<$name>

Format a name server record.

=item * B<rr_PTR> I<$name>

Format a pointer (reverse lookup) record.

=item * B<rr_MX> I<$preference, $name>

Format a mail exchanger record.

=item * B<rr_SOA> I<$mname, $rname, $serial, $refresh, $retry, $expire, $min>

Format a start of authority record.

=item * B<rr_TXT> I<$text>

Format a text record.

=back

=head1 CONSTANTS

B<isrcore::Stanford::DNS> defines many DNS constants.  The most commonly used
are listed below.  Please refer to the source for the rest.

=over

=item * B<QPTR>

Pointer to the original question in a DNS packet.

=item * B<T_A>

Address record type.

=item * B<T_NS>

Name server record type.

=item * B<T_CNAME>

Canonical name (alias) record type.

=item * B<T_SOA>

Start of authority record type.

=item * B<T_PTR>

Pointer record type.

=item * B<T_MX>

Mail exchanger record type.

=item * B<T_TXT>

Text record type.

=item * B<C_IN>

Internet record class.

=item * B<C_ANY>

Any record class.

=item * B<NOERROR>

Success code.

=item * B<FORMERR>

Unable to interpret the query error code.

=item * B<SERVFAIL>

Problem with the name server error code.

=item * B<NXDOMAIN>

The domain name does not exist error code.

=item * B<NOTIMP>

Not implemented error code.

=item * B<REFUSED>

Query disallowed by policy error code.

=back

=head1 SEE ALSO

isrcore::Stanford::DNSserver

=cut
