package XML::Cache;

# Effect Games Engine and IDE v1.0
# Copyright (c) 2005 - 2011 Joseph Huckaby
# Source Code released under the MIT License: 
# http://www.opensource.org/licenses/mit-license.php

##
# Cache XML trees in memory using XML::Lite
# Only check files for modification every N seconds
# 
# Usage:
#	my $xml = XML::Cache->new(
#		file => 'myfile.xml',    # same as XML::Lite
#		preserveAttributes => 1, # same as XML::Lite
#		cacheTime => 60          # default to 60 seconds
#	);
#	my $tree = $xml->getTree();
##

use strict;
use XML::Lite;

our @ISA = ('XML::Lite');

sub new {
	##
	# Class constructor, setup XML::Lite object
	##
	my $self = XML::Lite::new(@_);
	
	$self->{cacheTime} ||= 60;
	$self->{modDate} = (stat($self->{file}))[9];
	$self->{lastCheck} = time();
	
	return $self;
}

sub getTree {
	##
	# Return tree in memory if recent, or check file for changes
	##
	my $self = shift;
	
	if (time() - $self->{lastCheck} >= $self->{cacheTime}) {
		my $mod_date = (stat($self->{file}))[9];
		if ($mod_date != $self->{modDate}) {
			$self->reload();
			$self->{modDate} = $mod_date;
		}
		$self->{lastCheck} = time();
	}
	
	return $self->SUPER::getTree();
}

1;
