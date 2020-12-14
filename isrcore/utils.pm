###############
# utils.pm
# 
# Copyright 2010 Francisco Amato
# 
# This file is part of isr-evilgrade, www.faradaysec.com .
# 
# isr-evilgrade is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation version 2 of the License.
# 
# isr-evilgrade is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with isr-evilgrade; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
# 
# '''
##   

package isrcore::utils;
use strict;

#external modules
use Data::Dump qw(dump);
use Digest::MD5;
use Digest::SHA;

my $options = {
};
my $base = {
    'options' => $options
};

##########################################################################
# FUNCTION	new
# RECEIVES
# RETURNS
# EXPECTS
# DOES		class's constructor
sub new {
    my $class = shift;
    my $self = {'Base' => $base, @_ };
    return bless $self, $class;
}

##########################################################################
# FUNCTION	RndAlpha
# RECEIVES
# RETURNS
# EXPECTS
# DOES		Random Alphanumeric text
sub RndAlpha {
  my $size = int(shift());
  my @chars = @_ ? split('', shift) : ('A' .. 'Z', 'a' .. 'z', '0' .. '9');

  my $data;
  while($size--) {
    $data .= $chars[int(rand(@chars))];
  }
  return($data);
}

##########################################################################
# FUNCTION	RndNum
# RECEIVES
# RETURNS
# EXPECTS
# DOES		Random Number
sub RndNum {
  my $size = int(shift());
  my @chars = @_ ? split('', shift) : ('0' .. '9');

  my $data;
  while($size--) {
    $data .= $chars[int(rand(@chars))];
  }
  return($data);
}


##########################################################################
# FUNCTION	InverseChars
# RECEIVES
# RETURNS
# EXPECTS
# DOES		inverse a string of chars, include all the bytes it doesn't include...
# 		inverse of 0x00 .. 0x80 = 0x81 .. 0xff, etc
sub InverseChars {
  my $badChars = shift;
  my $chars;
  foreach my $c (0x00 .. 0xff) {
    $c = chr($c);
    if(index($badChars, $c) == -1) {
      $chars .= $c;
    }
  }
  return($chars);
}

##########################################################################
# FUNCTION	RndChars
# RECEIVES
# RETURNS
# EXPECTS
# DOES		size, BadCharsString...
sub RndChars {
  my $size = int(shift());
  my $badChars = shift;
  my @chars = split('', InverseChars($badChars));
  my $data;

  while($size--) {
    $data .= $chars[int(rand(@chars))];
  }

  return($data);
}

##########################################################################
# FUNCTION	RndData
# RECEIVES
# RETURNS
# EXPECTS
# DOES		Random Data
sub RndData {
  my $size = int(shift());
  my $string;

  for(my $i = 0; $i < $size; $i++) {
    $string .= chr(int(rand(256)));
  }

  return($string);
}

##########################################################################
# FUNCTION	getmd5
# RECEIVES
# RETURNS	md5hash, error
# EXPECTS
# DOES		get md5 hash
sub getmd5 {
  my ($file) = @_;
  open(FZ,$file) || return ("md5-fail",1);
  my $ctx = Digest::MD5->new;
  $ctx->addfile(*FZ);
  my $dig = $ctx->hexdigest;
  close(FZ);
  return $dig;
}

##########################################################################
# FUNCTION	getsha256
# RECEIVES
# RETURNS	md5hash, error
# EXPECTS
# DOES		get md5 hash
sub getsha256 {
  my ($file) = @_;
  open(FZ,$file) || return ("sha256-fail",1);
  my $ctx = Digest::SHA->new(256);
  $ctx->addfile(*FZ);
  my $dig = $ctx->hexdigest;
  close(FZ);
  return $dig;
}

1;
