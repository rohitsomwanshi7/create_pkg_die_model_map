#!usr/bin/perl
use strict;
use warnings;
use Data::Dumper;

my $pkg_map_file = $ARGV[0];
my $sp_file = $ARGV[1];
my $die_map_out_file = $ARGV[2];

############################################

my %data_db;

readSpFile($sp_file, \%data_db);
readPkgFile($pkg_map_file, \%data_db);
writeFile($die_map_out_file, \%data_db);

#print Dumper \%data_db;


##############################################

sub readPkgFile {
    my $pkg_file = shift;
    my $ref_data_db = shift;

    my $fh;
    open($fh, $pkg_file) or die("Cannot read file $pkg_file");
    my @data = <$fh>;
    close($fh);

    foreach my $line (@data) {
        chomp($line);
#        print "|$line| end\n";
        if ($line =~ /^(.*?)\s+pin\s+(.*?)\s*$/) {
            push @{$ref_data_db->{$2}{'pkg_ports'}}, $1;
        }
    }

    return 1;
##############################################

sub readSpFile {
    my $sp_file = shift;
    my $ref_data_db = shift;

    my $fh;
    open($fh, $sp_file) or die("Cannot read file $sp_file");
    my @data = <$fh>;
    close($fh);

    my $read_flag = 0;
    foreach my $line (@data) {
        chomp($line);
        if ($line =~ /^\*\s+\[MCP Begin\]$/) {
            $read_flag = 1;
        }
        if ($line =~ /^\* \[MCP END\]$/) {
            $read_flag = 0;
        }
        if ($read_flag == 1) {
            if ($line =~ /^\*\s+(\w.*?)\s+(.*?)\s+.*$/) {
                push @{$ref_data_db->{$1}{'die_model_ports'}}, $2;
            }
        }
    }

    return 1;
}

##############################################

sub writeFile {
    my $die_map_out_file = shift;
    my $ref_data_db = shift;

    my $fh_out;
    open($fh_out, ">$die_map_out_file") or die("Cannot create file $die_map_out_file");
    print $fh_out "\n";
    foreach my $vsrc (sort keys %{$ref_data_db}) {
        if (defined $ref_data_db->{$vsrc}{'pkg_ports'} && defined $ref_data_db->{$vsrc}{'die_model_ports'}) {
            my @pkg_ports = @{$ref_data_db->{$vsrc}{'pkg_ports'}};
            my @die_model_ports = @{$ref_data_db->{$vsrc}{'die_model_ports'}};
            foreach my $die_model_port (@die_model_ports) {
                foreach my $pkg_port (@pkg_ports) {
                    print $fh_out "\n$die_model_port pkg $pkg_port";
                }
            }
        }
    }
    close ($fh_out);
    return 1;
}
