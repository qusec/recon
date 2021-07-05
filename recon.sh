#!/usr/bin/sh

echo "This is my recon script"

while getopts ":d:t:o:" arg; do
  case $arg in
    d) target=$OPTARG;;
    t) threads=$OPTARG;;
    o) output_dir=$OPTARG;;
  esac
done
echo -e "\n$target  $threads   $output_dir\n"

if [ -z "${target}" ]; then
    echo "Invalid arguments\nUsage: ./recon.sh -d example.com -t concurrency (default 25) -o folder (default .)"
    exit 1
fi

#target=$1
#threads=$2
#output_dir=$3

if [ -z "$threads" ]
then
    threads=25
fi

if [ -z $output_dir ]
then
    output_dir="."
fi

echo "./recon.sh -d $target -t $threads -o $output_dir"

project_path=$output_dir/$target
mkdir -p $project_path
results=$project_path/domains.txt
active_results=$project_path/active-domains.txt
port=9090

run_httpserver() {
    pkill -f "python3 -m http.server $port"
    python3 -m http.server $port --directory $project_path >/dev/null 2>&1 &
    http_pid=$!
    echo "you can access the recon results here http://localhost:"$port

}

run_sublister() {
    sublist3r_dir=$project_path/sublist3r
    mkdir -p $sublist3r_dir
    sublist3r -d $target -t $threads -o $sublist3r_dir/$target.txt
    cat $sublist3r_dir/$target.txt | anew $results
}

run_assetfinder() {
    assetfinder_dir=$project_path/assetfinder
    mkdir -p $assetfinder_dir
    echo $target | assetfinder -subs-only | anew $assetfinder_dir/$target.txt
    cat $assetfinder_dir/$target.txt | anew $results
}

run_subfinder() {
    subfinder_dir=$project_path/subfinder
    mkdir -p $subfinder_dir
    subfinder -d $target -t $threads -silent -o $subfinder_dir/$target.txt
    cat $subfinder_dir/$target.txt | anew $results
}

run_httprobe() {
    cat $results | httprobe -c $threads | anew $active_results
}

run_fff() {
    fff_dir=$project_path/fff
    cat $active_results | fff -d 5 -S -o $fff_dir
}

run_aquatone() {
    aquatone_dir=$project_path/aquatone
    mkdir -p $aquatone_dir
    cat $active_results | aquatone -scan-timeout 1000 -chrome-path=/usr/bin/chromium -out $(pwd)/$aquatone_dir
}


# run http service to server the recon results
run_httpserver

# Discovery
run_sublister
run_assetfinder
run_subfinder

# http probe
run_httprobe

# dump body and headers
run_fff

# screenshots
run_aquatone

echo "To stop the http service run command => kill "$http_pid
