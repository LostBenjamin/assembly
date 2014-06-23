
use strict;
use Carp;
use Data::Dumper;
use Getopt::Long;
Getopt::Long::Configure("pass_through");

my $usage = <<End_of_Usage;

Usage: ar-run  [-h] 
               [-f [SINGLE [SINGLE ...]]]
               [--pair [PAIR [PAIR ...]]] [--single [SINGLE [SINGLE ...]]]
               [--data DATA_ID]
               [--reference [REFERENCE [REFERENCE ...]]]
               [-a [ASSEMBLERS [ASSEMBLERS ...]] |
                -p [PIPELINE [PIPELINE ...]] |
                -r [RECIPE [RECIPE ...]] |
                -w [WASP [WASP ...]]]
               [-m MESSAGE] [--curl]
               [-s server_addr]

Run an Assembly RAST job

Optional arguments:
  -h, --help            show this help message and exit
  -s server_addr        Specify ARAST server address
  -f [SINGLE [SINGLE ...]]
                        specify sequence file(s)
  --reference [REFERENCE [REFERENCE ...]]
                        specify sequence file(s)
  -a [ASSEMBLERS [ASSEMBLERS ...]], --assemblers [ASSEMBLERS [ASSEMBLERS ...]]
                        specify assemblers to use. None will invoke automatic
                        mode
  -p [PIPELINE [PIPELINE ...]], --pipeline [PIPELINE [PIPELINE ...]]
                        invoke a pipeline. None will invoke automatic mode
  -r [RECIPE [RECIPE ...]], --recipe [RECIPE [RECIPE ...]]
                        invoke a recipe
  -w [WASP [WASP ...]], --wasp [WASP [WASP ...]]
                        invoke a wasp expression
  -m MESSAGE, --message MESSAGE
                        Attach a description to job
  --data DATA_ID        Reuse uploaded data
  --pair [PAIR [PAIR ...]]
                        Specify a paired-end library and parameters
  --single [SINGLE [SINGLE ...]]
                        Specify a single end file and parameters
  --curl                Use curl for http requests

End_of_Usage

my $help;
my $server;

my $rc = GetOptions("h|help" => \$help,
                    "s=s" => \$server);

$rc or die $usage;
if ($help) {
    print $usage;
    exit 0;
}

my $arast = 'arast';
$arast .= " -s $server" if $server;

my $have_data;
my $argv;
for (@ARGV) {
    if (/ /) { $argv .= "\"$_\" " } else { $argv .= "$_ " }
    $have_data = 1 if /(-f|--single|--pair|--data)/;
}

if (!$have_data) {
    my @lines = <STDIN>;
    my $line = pop @lines;
    my ($data_id) = $line =~ /(\d+)/;
    $argv .= "--data $data_id";
}

system "$arast run $argv";

