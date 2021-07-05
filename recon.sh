#!/usr/bin/sh

echo "This is my recon script"

target=$1
threads=$2
results=$target/domains.txt
active_results=$target/active-domains.txt
port=9090

run_httpserver() {
    python3 -m http.server $port --directory $target >/dev/null 2>&1 &
    http_pid=$!
    echo "you can access the recon results here http://localhost:"$port

}

run_sublister() {
    sublist3r_dir=$target/sublist3r
    mkdir -p $sublist3r_dir
    sublist3r -d $target -t $threads -o $sublist3r_dir/$target.txt
    cat $sublist3r_dir/$target.txt | anew $results
}

run_assetfinder() {
    assetfinder_dir=$target/assetfinder
    mkdir -p $assetfinder_dir
    echo $target | assetfinder -subs-only | anew $assetfinder_dir/$target.txt
    cat $assetfinder_dir/$target.txt | anew $results
}

run_httprobe() {
    cat $results | httprobe -c $threads | anew $active_results
}

run_aquatone() {
    aquatone_dir=$target/aquatone
    mkdir -p $aquatone_dir
    cat $active_results | aquatone -scan-timeout 1000 -out $aquatone_dir
}

# run http service to server the recon results
run_httpserver

# Discovery
run_sublister
run_assetfinder

# http probe
run_httprobe

# screenshots
run_aquatone

echo "To stop the http service run command => kill "$http_pid
