#!/usr/bin/perl

# Amazon reviews downloader
# Copyright (C) 2015  Andrea Esuli
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

use strict;
use LWP::UserAgent; 
use HTTP::Request;
use File::Path;

my ($thread_id, $amazon_id, $f_page, $l_page, $domain, $temp_dir) = @ARGV;

chomp ($thread_id);
chomp ($amazon_id);
chomp ($f_page);
chomp ($l_page);
chomp ($domain);
chomp ($temp_dir);

if (length $f_page == 0) {
  $f_page = 1;
}
if (length $l_page == 0) {
  $l_page = 1;
}
if (length $domain == 0) {
  $domain = "com";
}

print "\nAmazon ID = $amazon_id, First Page = $f_page, Last Page = $l_page, domain = $domain\n";

mkdir "$temp_dir";
mkdir "$temp_dir/$domain";

my $count = 0;

if ($amazon_id) {

    my $dir = "$temp_dir/$domain/$amazon_id";
    mkdir $dir;

    my $urlPart1 = "https://www.amazon.".$domain."/product-reviews/";
    my $urlPart2 = "/?ie=UTF8&showViewpoints=0&pageNumber=";
    my $urlPart3 = "&sortBy=bySubmissionDateDescending";

    my $referer = $urlPart1.$amazon_id.$urlPart2."1".$urlPart3;

    my $page = $f_page;
    my $lastPage = $l_page;
    my $sleepTime = 2;
    while($page<=$lastPage) {

		my $url = $urlPart1.$amazon_id.$urlPart2.$page.$urlPart3;
                my $cmd = "curl -s -o $dir/$page \"$url\"";
                #print $cmd;
                system($cmd);
		++$page;
    }
}
system("touch $temp_dir/$thread_id");
