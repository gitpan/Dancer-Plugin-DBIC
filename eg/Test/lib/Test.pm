package Test;
use lib '../../lib';
use Dancer ':syntax';
use Dancer::Plugin::DBIC;
use Data::Dumper qw/Dumper/;

our $VERSION = '0.1';

get '/' => sub {
    
    foo();
    
    my $this;
    $this = foo() for (1..4);
    
    die Dumper $this;
};

true;
