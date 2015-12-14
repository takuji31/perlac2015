#!/usr/bin/env perl
use Mojolicious::Lite;
use 5.22.0;
use experimental 'signatures';
use Data::UUID;
use Redis::Fast;

# Documentation browser under "/perldoc"
plugin 'PODRenderer';

get '/' => sub ($c) {
    $c->render(template => 'index');
};

get '/show/:uuid' => sub ($c) {
    my $redis = Redis::Fast->new;
    my $body = $redis->get($c->param('uuid'));
    if ($body) {
        $c->stash('body' => $body);
        $c->render(template => 'show');
    } else {
        $c->redirect_to('/');
    }
};

post '/' => sub ($c) {
    my $body = $c->param('body');
    my $redis = Redis::Fast->new;
    if ($body) {
        my $uuid = Data::UUID->new->create_str;
        $redis->set($uuid, $body);
        $c->redirect_to('showuuid', {uuid => $uuid});
    } else {
        $c->redirect_to('/');
    }
};

app->start;
__DATA__

@@ index.html.ep
% layout 'default';
% title 'NoPaste';
<h1>No Paste</h1>

%= form_for '/' => (method => 'POST') => begin
    %= text_area 'body', cols => '100', rows => '20'
    %= submit_button 'Paste'
% end

@@ show.html.ep
% layout 'default';
% title 'NoPaste';
<h1>No Paste</h1>

<pre>
%= $body
</pre>

@@ layouts/default.html.ep
<!DOCTYPE html>
<html>
  <head><title><%= title %></title></head>
  <body><%= content %></body>
</html>
