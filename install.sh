# Global variables 
main_dir=~/.mew 
main_executable=./bin/mew.sh
main_executable_c=./bin/mew
main_lib=./lib
bin_target=~/.mew/bin/
name=mew

go_faster=false
c_install=false

for i in "$@"; do
    if [[ $i = "--fast" ]]; then
        go_faster=true
    elif [[ $i = "--c" ]]; then
        c_install=true
    fi
done
 

function hold() {
    if $go_faster; then
        return 0
    fi
    sleep ${1:-.2}
}

# Giving Executable permission to the mew.sh file 
if [[ -f "./bin/mew.sh" ]]; then chmod +x ./bin/mew.sh; fi
# Giving Executable permission to the uninstall.sh file 
if [[ -f "./uninstall.sh" ]]; then chmod +x ./uninstall.sh; fi

old_mew_flag=false
# Creating folder structure for mew
if [[ -f $main_dir || -d $main_dir ]]; then 
    echo "Old mew directory found"
    hold
    old_mew_flag=true
    echo "Removing old mew directory"
    hold
    rm -rf $main_dir
fi

mkdir -p $main_dir
mkdir -p "$main_dir/bin/"

if $old_mew_flag; then
    echo -e "\e[33mReinstalling mew...\e[0m"
else 
    echo -e "\e[33mInstalling mew...\e[0m"
fi
hold 1

if $c_install; then 
    if command -v shc > /dev/null 2>&1; then
        shc -f ./bin/mew.sh -o ./bin/mew
        mv ./bin/mew.sh.x.c ./bin/mew.c
    else 
        echo "Please install 'csh' before continuing"
        exit
    fi
fi
# Copying mew binary and library to main directory
echo "Setting up Mew..."
hold
if $c_install; then
    cp -rf -p $main_executable_c $bin_target
    echo "Setting up c binary..."
else 
    cp -rf -p $main_executable $bin_target/$name
    echo "Setting up script..."
fi
echo "Setting up library"
hold
cp -rf -p $main_lib $main_dir

# Setting environment variables for mew 
echo "Adding environmental variables"
hold
export_query='export PATH="$PATH:$HOME/.mew/bin/"' 
shell_targets=(~/.bashrc ~/.config/fish/config.fish ~/.zshrc ~/.kshrc ~/.tcshrc ~/.cshrc)

# Checking if SHELL available 
for shell_target in ${shell_targets[@]}; do
    if [[ -f $shell_target ]]; then 
        if ! grep -q "$export_query" $shell_target; then
            {
                echo -e "\n# mew path"
                echo $export_query
            } >> $shell_target
        fi
    fi
done

echo -e "\e[32mMew installed...\e[0m"
hold 0