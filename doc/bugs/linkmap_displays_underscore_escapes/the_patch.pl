From efbb1121ffdc146f5c9a481a51f23ad151b9f240 Mon Sep 17 00:00:00 2001
From: chrysn <chrysn@fsfe.org>
Date: Thu, 15 Mar 2012 14:38:42 +0100
Subject: [PATCH] display the pagetitle() in linkmaps

without this patch, linkmaps display underscores and underscore escape
sequences in the rendered output.

this introduces a pageescape function, which invoces pagetitle() to get
rid of underscore escapes and wraps the resulting utf8 string
appropriately for inclusion in a dot file (using dot's html encoding
because it can represent the '\"' dyad properly, and because it doesn't
need special-casing of newlines).
---
 IkiWiki/Plugin/linkmap.pm |   17 +++++++++++++++--
 1 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/IkiWiki/Plugin/linkmap.pm b/IkiWiki/Plugin/linkmap.pm
index ac26e07..b5ef1a1 100644
--- a/IkiWiki/Plugin/linkmap.pm
+++ b/IkiWiki/Plugin/linkmap.pm
@@ -5,6 +5,7 @@ use warnings;
 use strict;
 use IkiWiki 3.00;
 use IPC::Open2;
+use HTML::Entities;
 
 sub import {
        hook(type => "getsetup", id => "linkmap", call => \&getsetup);
@@ -22,6 +23,18 @@ sub getsetup () {
 
 my $mapnum=0;
 
+sub pageescape {
+       my $item = shift;
+       # encoding explicitly in case ikiwiki is configured to accept <> or &
+       # in file names
+       my $title = pagetitle($item, 1);
+       # it would not be necessary to encode *all* the html entities (<> would
+       # be sufficient, &" probably a good idea), as dot accepts utf8, but it
+       # isn't bad either
+       $title = encode_entities($title);
+       return("<$title>");
+}
+
 sub preprocess (@) {
        my %params=@_;
 
@@ -63,7 +76,7 @@ sub preprocess (@) {
        my $show=sub {
                my $item=shift;
                if (! $shown{$item}) {
-                       print OUT "\"$item\" [shape=box,href=\"$mapitems{$item}\"];\n";
+                       print OUT pageescape($item)." [shape=box,href=\"$mapitems{$item}\"];\n";
                        $shown{$item}=1;
                }
        };
@@ -74,7 +87,7 @@ sub preprocess (@) {
                        foreach my $endpoint ($item, $link) {
                                $show->($endpoint);
                        }
-                       print OUT "\"$item\" -> \"$link\";\n";
+                       print OUT pageescape($item)." -> ".pageescape($link).";\n";
                }
        }
        print OUT "}\n";
-- 
1.7.9.1
