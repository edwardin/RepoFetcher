#! /bin/bash


# Checks if the USER environment variable is set. If not, it prompts the user to enter their username.
if [ -z "$USER" ]; then
    echo "User name is not set. Please enter your user name:"
    read USER
fi

# Clones a repository from a given URL if it doesn't already exist in the current directory.
function clone_repo() {
    local repo=$1
    local url=$2
    if [[ ! -d $(basename $repo) ]]; then
        git clone "$url"
    fi
}

# Sets up a commit-msg hook for a given repository.
function setup_commit_msg_hook() {
    local repo=$1
    pushd "$repo" >/dev/null
    local gitdir=$(git rev-parse --git-dir)
    curl -o ${gitdir}/hooks/commit-msg https://<YOUR_GERRIT_REPO_URL>/gerrit/static/commit-msg
    chmod +x ${gitdir}/hooks/commit-msg
    popd >/dev/null
}

# Adds a GitLab remote to a given repository.
function add_gitlab_remote() {
    local repo=$1
    pushd "$repo" >/dev/null
    git remote add gitlab git@<GITLAB_URL>:<MODULE>/code/$repo.git
    popd >/dev/null
}

# Clones a repository from the RPSW directory, sets up a commit-msg hook.
function RPSW() {
    local repo=$1
    local url="ssh://${USER}@<YOUR_GERRIT_REPO_URL>:29418/YOUR/MODULE$repo"
    clone_repo $repo $url
    setup_commit_msg_hook $repo
}

# Clones a repository from the RPSW_INTERNAL directory and sets up a commit-msg hook, and adds a GitLab remote.
function RPSW_INTERNAL() {
    local repo=$1
    local url="ssh://${USER}@<YOUR_GERRIT_REPO_URL>:29418/YOUR/MODULEinternal/$repo"
    clone_repo $repo $url
    setup_commit_msg_hook $repo
    add_gitlab_remote $repo
}

# Clones a repository from the RFSW_INTERNAL directory.
function RFSW_INTERNAL() {
    local repo=$1
    local url="ssh://${USER}@<YOUR_GERRIT_REPO_URL>:8282/YOUR/MODULE$repo"
    clone_repo $repo $url
}

# Clones a list of SHF repositories.
function clone_SHF_repos() {
    local repos=("$@")
    for repo in "${repos[@]}"; do
        case $repo in
        "meta-SHF" | "SHF")
            RPSW $repo
            ;;
        *)
            RPSW_INTERNAL $repo
            ;;
        esac
    done
}

# Clones a list of RFS repositories.
function clone_rfs_repos() {
    local repos=("$@")
    for repo in "${repos[@]}"; do
        RFSW_INTERNAL $repo
    done
}

# Clones the meta-SHF and SHF repositories.
function SHF_meta() {
    local repos=("meta-SHF" "SHF")
    clone_SHF_repos "${repos[@]}"
}

# Clones a list of SHF and RFSW repositories for the SHF_dev project.
function SHF_dev() {
    local SHF_repos=("coco" "coco-ifc" "lola" "cofi" "coma" "swman" "syscon")
    clone_SHF_repos "${SHF_repos[@]}"
    local rf_repos=("uoam" "uoam-rp3")
    clone_rfsw_repos "${rf_repos[@]}"
}

# Clones a list of RFS repositories for the rfsw_dev project.
function rfsw_dev() {
    local repos=("ccs" "mf" "sf" "hlapi" "hlapi-messages" "logging" "uoam" "uoam-rp3" "frm-common")
    clone_rfsw_repos "${repos[@]}"
}

# Clones a list of repositories for the SHF_study project.
function SHF_study() {
    SHF_dev
    rfsw_dev
    git clone ssh://${USER}@<YOUR_GERRIT_REPO_URL>:8282/MN/ATF/3DAAS-PoC/svn/conn-user
}

# Clones a repository from the BKID directory if it doesn't already exist in the current directory.
function BKID() {
    if [[ ! -d $(basename $1) ]]; then
        git clone "git@<YOUR_GIT_REPO>:bkid/${1}.git"
    else
        echo "Directory already exists"
    fi
}

# Clones the bkid-yocto repository.
function SHF_lfs() {
    BKID bkid-yocto
}
