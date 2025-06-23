ask_to_user() {
    local answer=""
    if [ -n "$2" ]; then
        read -p "$1 " answer
        if [ -n "$answer" ]; then
            echo "$answer"
            return
        else
            echo "$2"
            return
        fi
    fi

    while true; do
        read -p "$1 " answer
        # Check if the alias is not empty
        if [ -n "$answer" ]; then
            break
        fi
    done
    echo "$answer"
}

echo "
This script will create a ceremony.env file with the following content:
    * TARGET_CIRCUITS: the list of iden3 circuits to be used in the ceremony
    * INPUT_PTAU: the path to the input ptau file
    * CEREMONY_BRANCH: the name of the ceremony (and its branch)
    * CONTRIBUTIONS_PATH: the path to the folder to store the contributions files
    * OUTPUT_PATH: the path to the folder to store the resulting files
"

if ! command -v git-lfs &>/dev/null; then
    echo "Git LFS is not installed. Please install and run 'git lfs install' before running this script."
fi

ceremony_branch=$(ask_to_user "Please enter the name of the ceremony (and its branch default (ceremony/v3-circuits): " "v3-circuits")
contributions_path=$(ask_to_user "Please enter the path to the folder to store the contributions files (by default './contributions'): " "./contributions")
output_path=$(ask_to_user "Please enter the path to the folder to store the resulting files (by default './results'): " "./results")
target_circuits=$(ask_to_user "Please enter the list of iden3 circuits to be used in the ceremony (by default 'authV3'): " "authV3")

echo "TARGET_CIRCUITS=$target_circuits
CEREMONY_BRANCH=ceremony/$ceremony_branch
CONTRIBUTIONS_PATH=$contributions_path
OUTPUT_PATH=$output_path" >ceremony.env

git checkout -b ceremony/$ceremony_branch &&
    git add -f ceremony.env &&
    git commit -m "Initialize ceremony" &&
    git push origin ceremony/$ceremony_branch

# Ensure the repository is set explicitly in the PR creation command
NEW_BRANCH_NAME=ceremony/$ceremony_branch
MAIN_BRANCH=main
gh pr create --repo "$GITHUB_REPO" --title "Contribution: from $NEW_BRANCH_NAME to '$MAIN_BRANCH' ceremony" --body "" --base "$MAIN_BRANCH" --head "$NEW_BRANCH_NAME" || {
    echo "Failed to create pull request"
    exit 1
}