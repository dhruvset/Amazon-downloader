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

my $ua = LWP::UserAgent->new;
$ua->timeout(10);
$ua->env_proxy;
#$ua->agent('Mozilla/5.0 (X11; Linux i686) AppleWebKit/534.30 (KHTML, like Gecko) Ubuntu/11.04 Chromium/12.0.742.91 Chrome/12.0.742.91 Safari/534.30');

mkdir "$temp_dir";
mkdir "$temp_dir/$domain";

my $count = 0;

if ($amazon_id) {

    my $dir = "$temp_dir/$domain/$amazon_id";
    mkdir $dir;

    my $urlPart1 = "http://www.amazon.".$domain."/product-reviews/";
    my $urlPart2 = "/?ie=UTF8&showViewpoints=0&pageNumber=";
    my $urlPart3 = "&sortBy=bySubmissionDateDescending";

    my $referer = $urlPart1.$amazon_id.$urlPart2."1".$urlPart3;

    my $page = $f_page;
    my $lastPage = $l_page;
    my $sleepTime = 2;
    while($page<=$lastPage) {

		my $url = $urlPart1.$amazon_id.$urlPart2.$page.$urlPart3;
		###print $url;
		my $request = HTTP::Request->new(GET => $url);
		$request->referer($referer);

		my $response = $ua->request($request);
		if($response->is_success) {
			print " GOTIT\n";
			my $content = $response->decoded_content;

			while($content =~ m#cm_cr_arp_d_paging_btm_([0-9]+)#gs ) {
				my $val = $1+0;
				if($val>$lastPage) {
					$lastPage = $val;
				}
			}
    $lastPage = $l_page;
			
			if(open(CONTENTFILE, ">./$dir/$page")) {
				binmode(CONTENTFILE, ":utf8");
				print CONTENTFILE $content;
				close(CONTENTFILE);
				print "ok\t$domain\t$amazon_id\t$page\t$lastPage\n";
			}
			else {
				print "failed\t$domain\t$amazon_id\t$page\t$lastPage\n";
			}
			
			if($sleepTime>0) {
			#	--$sleepTime;
			}
		}
		else {
			if($response->code==503) {
				--$page;
				#++$sleepTime;
				print " URL=$url , TIMEOUT ".$response->code." retrying (new timeout $sleepTime)\n";
			}
			else {
				print " Downloaded ". ($page-1). " pages for product id $amazon_id (end code:".$response->code.")\n";
				last;
			}
		}
		++$page;
		sleep($sleepTime);
    }
}
system("touch $temp_dir/$thread_id");

