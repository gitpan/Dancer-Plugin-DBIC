# ABSTRACT: DBIx::Class interface for Dancer applications

package Dancer::Plugin::DBIC;
BEGIN {
  $Dancer::Plugin::DBIC::VERSION = '0.12';
}

use strict;
use warnings;
use Dancer::Plugin;
use DBIx::Class;
use DBIx::Class::Schema::Loader qw/ make_schema_at /;

my  $cfg = plugin_setting;
my  $DBH = {};


foreach my $keyword (keys %{ $cfg }) {
    register $keyword => sub {
        my @dsn = ();
        
        $cfg->{$keyword}->{pckg} =~ s/\-/::/g;
        
        push @dsn, $cfg->{$keyword}->{dsn}      if $cfg->{$keyword}->{dsn};
        push @dsn, $cfg->{$keyword}->{user}     if $cfg->{$keyword}->{user};
        push @dsn, $cfg->{$keyword}->{pass}     if $cfg->{$keyword}->{pass};
        
        make_schema_at(
            $cfg->{$keyword}->{pckg},
            {},
            [ @dsn ],
        ) if $cfg->{$keyword}->{generate} == 1;
        
        push @dsn, $cfg->{$keyword}->{options}  if $cfg->{$keyword}->{options};
        
        my  $variable = lc $cfg->{$keyword}->{pckg};
            $variable =~ s/::/\-/g;
            
        my  $package  = $cfg->{$keyword}->{pckg};
        
        unless ( $Dancer::Plugin::DBIC::DBH->{$keyword}->{$variable} ) {
            $Dancer::Plugin::DBIC::DBH->{$keyword}->{$variable} =
            $package->connect(@dsn);
        }
        
        return $Dancer::Plugin::DBIC::DBH->{$keyword}->{$variable};
    };
}

register_plugin;

1;
__END__
=pod

=head1 NAME

Dancer::Plugin::DBIC - DBIx::Class interface for Dancer applications

=head1 VERSION

version 0.12

=head1 SYNOPSIS

    # Dancer Configuration File
    plugins:
      DBIC:
        foo:
          pckg: "Foo::Bar"
          dsn:  "dbi:mysql:db_foo"
          user: "root"
          pass: "****"
          options:
            RaiseError: 1
            PrintError: 1
    
    # Important Note! We have reversed our policy so that D::P::DBIC will not
    # assume to automatically generate your DBIx-Class Classes, to enable DBIx-Class
    # generation, please use the following configuration
    plugins:
      DBIC:
        foo:
          generate: 1
    
    # Dancer Code File
    use Dancer;
    use Dancer::Plugin::DBIC;

    # Calling the `foo` dsn keyword will return a L<DBIx::Class> instance using
    # the database connection specifications associated with the dsn keyword
    # within the Dancer configuration file.
    
    get '/profile/:id' => sub {
        my $users_rs = foo->resultset('Users')->search({
            user_id => params->{id}
        });
        
        template 'user_profile', { user_data => $user_rs->next };
    };

    dance;

Database connection details are read from your Dancer application config - see
below.

=head1 DESCRIPTION

Provides an easy way to obtain a DBIx::Class instance by simply calling a dsn keyword
you define within your Dancer configuration file, this allows your L<Dancer>
application to connect to one or many databases with ease and consistency.

=head1 CONFIGURATION

Connection details will be taken from your Dancer application config file, and
should be specified as stated above, for example: 

    plugins:
      DBIC:
        foo:
          pckg: "Foo"
          dsn:  "dbi:mysql:db_foo"
          user: "root"
          pass: "****"
          options:
            RaiseError: 1
            PrintError: 1
        bar:
          pckg: "Bar"
          dsn:  "dbi:SQLite:dbname=./foo.db"

Please use dsn keywords that will not clash with existing L<Dancer> and
Dancer::Plugin::*** reserved keywords. 

Each database configuration *must* have a dsn and pckg option. The dsn option
should be the L<DBI> driver connection string less the optional user/pass and
arguments options. The pckg option should be a proper Perl package name that
Dancer::Plugin::DBIC will use as a DBIx::Class schema class. Optionally a database
configuation may have user, pass and options paramters which are appended to the
dsn in list form, i.e. dbi:SQLite:dbname=./foo.db, $user, $pass, $options.

=head1 AUTHOR

Al Newkirk <awncorp@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by awncorp.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

