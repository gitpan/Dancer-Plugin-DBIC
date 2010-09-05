package Test;
use lib '../../lib';
use Dancer ':syntax';
use Dancer::Plugin::DBIC;
use Data::Dumper qw/Dumper/;

our $VERSION = '0.1';

get '/' => sub {
    
    print Dumper foo->resultset('User')->all;
    
    exit;
};

true;
