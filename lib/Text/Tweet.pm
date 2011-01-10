package Text::Tweet;
# ABSTRACT: Optimize a tweet based on given keywords

use Moo;

has maxlen => (
	is => 'ro',
	default => sub { 140 },
);

has hash => (
	is => 'ro',
	default => sub { '#' },
);

has hash_re => (
	is => 'ro',
	default => sub { '\#' },
);

has hashtags_at_end => (
	is => 'ro',
	default => sub { 0 },
);

sub make_tweet {
	my ( $self, $text, $url, $keywords ) = @_;
	
	my @keywords = @{$keywords};

	my $part = $text;
	my @parts = split(/[\n\r\t ]+/,$text);
	shift @parts if !$parts[0];
	my $url_count = 0;
	$url_count += length($url) + 1 if $url;
	my @newparts;
	my @used_keywords;
	my $hash = $self->hash;
	my $hash_re = $self->hash_re;
	for my $keyword (@keywords) {

		my $hkeyword = lc($keyword);
		$hkeyword =~ s/[^\w]//ig;
		$hkeyword = $hash.$hkeyword;

		my $count = length(join(' ',@parts,@newparts)) + $url_count;

		if (!grep { lc($_) eq lc($hkeyword) } @used_keywords) {
			push @used_keywords, $hkeyword;
			
			my $push_to_end = 0;
			
			if (!$self->hashtags_at_end) {
				my $current_text = join(' ',@parts);
				$current_text =~ s/($keyword)/$hash$1/i;
				if ($current_text ne join(' ',@parts)) {
					@parts = split(/ /,$current_text);
				} else {
					$push_to_end = 1;
				}
			}
			
			if ($push_to_end || $self->hashtags_at_end) {
				if ($count + 1 + length($hkeyword) <= $self->maxlen) {
					push @newparts, $hkeyword;
				}
			}

		}

	}
	push @parts, $url if $url;
	push @parts, @newparts;
	
	return join(" ",@parts);
}

1;
