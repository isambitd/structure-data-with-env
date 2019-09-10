## Cleaning Docker images
function clean_images {
    if docker images | awk '{ print $1,$3 }' | grep none
    then 
        docker images | awk '{ print $1,$3 }' | grep none | awk '{print $2 }' | xargs -I {} docker rmi {}
    fi
    if docker images | awk '{ print $1,$3 }' | grep yellow-img
    then 
        docker images | awk '{ print $1,$3 }' | grep yellow-img | awk '{print $2 }' | xargs -I {} docker rmi {}
    fi
}
function clean_containers {
    if docker ps -a | grep Exit
    then 
        docker ps -a | grep Exit | cut -d ' ' -f 1 | xargs docker rm
    fi
    if docker ps -a | grep Created
    then
        docker ps -a | grep Created | cut -d ' ' -f 1 | xargs docker rm
    fi
    stop_and_clean_yellow_cont
}

function stop_and_clean_yellow_cont {
    container_id=`docker ps -aqf "name=yellow-cont" `
    if [ ! -z "$container_id" ]
    then 
        docker ps | awk '{ print $1 }' | grep "$container_id" | awk '{print $1 }' | xargs -I {} docker stop {}
    fi
    if [ ! -z "$container_id" ]
    then 
        docker rm $container_id
    fi
}

function check_longest_trips_is_ready {
    {
        if [[ -f trip_logs.txt ]]
        then
            > trip_logs.txt
        else
            touch trip_logs.txt
        fi
        docker logs $container_id &> trip_logs.txt
        longest_trips_is_ready=`cat trip_logs.txt | grep "longest_trips_file_generate_done!"`
    } || {
        longest_trips_is_ready=''
    }
}
function check_top_tips_is_ready {
    {
        if [[ -f tip_logs.txt ]]
        then
            > tip_logs.txt
        else
            touch tip_logs.txt
        fi
        docker logs $container_id &> tip_logs.txt
        top_tips_is_ready=`cat tip_logs.txt | grep "top_tips_file_generate_done!"`
    } || {
        top_tips_is_ready=''
    }
}

function download_longest_file {
    echo "Waiting for longest_trips_per_day to download"
    check_longest_trips_is_ready
    while [ -z "$longest_trips_is_ready" ]
        do
        echo "Waiting..."
        sleep 5
        check_longest_trips_is_ready
        done
    docker cp $container_id:/usr/app/longest_trips_per_day_by_sambit.csv ./outputs/
    echo "longest_trips_per_day file is downloaded in your local."
}

function download_top_tips {
    echo "Waiting for longest_trips_per_day to download"
    check_top_tips_is_ready
    while [ -z "$top_tips_is_ready" ]
        do
        echo "Waiting..."
        sleep 5
        check_top_tips_is_ready
        done
    docker cp $container_id:/usr/app/top_tipping_zones_by_sambit.csv ./outputs/
}

function build_run_and_download {
    docker build -t yellow-img -f ./Dockerfile .
    docker run -it --name=yellow-cont -d yellow-img
    container_id=`docker ps -aqf "name=yellow-cont" `
    # download_longest_file
    download_top_tips
}

function clean_and_start {
    clean_containers
    clean_images
    build_run_and_download
}

function start {
    stop_and_clean_yellow_cont
    build_run_and_download
}

start
echo "Thank you :)"