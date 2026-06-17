#!/system/bin/sh

LOG_FILE="/data/mdlog/tran_file.log"
LOG_PRINT_FLAG=false

# func: record log
log_message() {
    if [ "$LOG_PRINT_FLAG" = "true" ]; then
        local msg="$1"
        local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
        echo "$timestamp - $msg" | tee -a "$LOG_FILE" >&2
    fi
}

# func: parse parameter tran_file.init
parse_arguments() {
    caller=${1%%,*}
    variables=${1#*,}
    dir=${variables%%,*}
    file_end_with=${variables#*,}
}

# func: delete files that endwith file_end_with for dir 
delete_file_for_dir() {
    if [ -z "$dir" ] || [ -z "$file_end_with" ]; then
        log_message "Error: dir or file_end_with is not provided."
        return 1
    fi

    if [ ! -d "$dir" ]; then
        log_message "Error: Directory $dir does not exist."
        return 1
    fi

    find "$dir" -type f -name "*$file_end_with" -delete
    if [ $? -eq 0 ]; then
        setprop tran_file.ret "file_delete_succ"
        log_message "Deleted mdlog files with suffix $file_end_with in $dir"
        return 0
    else
        log_message "Error: Failed to delete files in $dir."
        return 1
    fi
}

# func: get file absolute path that endwith file_end_with for dir
get_filepath_for_dir() {
    if [ -z "$dir" ] || [ -z "$file_end_with" ]; then
        log_message "Error: dir or file_end_with is not provided."
        return 1
    fi

    if [ ! -d "$dir" ]; then
        log_message "Error: Directory $dir does not exist."
        return 1
    fi

    file_names=$(find "$dir" -type f -name "*$file_end_with")
    setprop tran_file.ret "$file_names"
    if [ $? -eq 0 ]; then
        log_message "Stored mdlog file names with suffix $file_end_with in tran_file.ret property."
        return 0
    else
        log_message "Error: Failed to set tran_file.ret property."
        return 1
    fi
}

parse_arguments "$1"
case $caller in
    "delete_file_for_dir")
        delete_file_for_dir
        ;;
    "get_filepath_for_dir")
        get_filepath_for_dir
        ;;
    *)
        log_message "unknown: $caller"
        ;;
esac