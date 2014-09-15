#!/usr/bin/perl
my $files = `find . | grep README.md`;
mkdir 'build';
for my $file ( split "\n", $files ) {
  my ( $path ) = $file =~ /\.\/(.*)\/README.md$/;
  $path = "build/$path";
  `mkdir -p $path`;
  `md2html $file > $path/index.html`;
  `perl -pi -e 's/href="[^"]*master\\\/([^"]*)"/href="\$1"/g' $path/index.html`;
  `perl -pi -e 's/href="([^"]*)"/href="\$1\\\/index.html"/g' $path/index.html`;
}
