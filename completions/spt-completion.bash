# Bash completion for spt (Simple Package Tool)
# 
# Installation:
#   sudo cp completions/spt-completion.bash /etc/bash_completion.d/spt
#   source ~/.bashrc
#
# Or for user installation:
#   mkdir -p ~/.local/share/bash-completion/completions
#   cp completions/spt-completion.bash ~/.local/share/bash-completion/completions/spt
#   source ~/.bashrc

_spt_completions() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    
    # Main commands
    local commands="create generate install list clean open --version --help -h -v"
    
    # If we're completing the first argument (command)
    if [ $COMP_CWORD -eq 1 ]; then
        COMPREPLY=( $(compgen -W "${commands}" -- ${cur}) )
        return 0
    fi
    
    # Get the command (first argument)
    local command="${COMP_WORDS[1]}"
    
    case "${command}" in
        create)
            case "${prev}" in
                create)
                    # Suggest GitHub username format
                    COMPREPLY=( $(compgen -W "username/repo" -- ${cur}) )
                    return 0
                    ;;
                -c|--code|-y|--yes|-h|--help)
                    # These flags don't take arguments
                    return 0
                    ;;
                *)
                    # Suggest flags for create
                    local flags="-c --code -y --yes -h --help"
                    COMPREPLY=( $(compgen -W "${flags}" -- ${cur}) )
                    return 0
                    ;;
            esac
            ;;
        generate)
            case "${prev}" in
                -o|--output)
                    # Complete directory paths
                    COMPREPLY=( $(compgen -d -- ${cur}) )
                    return 0
                    ;;
                -d|--dry-run|-h|--help)
                    # These flags don't take arguments
                    return 0
                    ;;
                *)
                    # Suggest flags for generate
                    local flags="-d --dry-run -o --output -h --help"
                    COMPREPLY=( $(compgen -W "${flags}" -- ${cur}) )
                    return 0
                    ;;
            esac
            ;;
        install)
            case "${prev}" in
                -h|--help)
                    # These flags don't take arguments
                    return 0
                    ;;
                *)
                    # Suggest flags for install
                    local flags="-h --help"
                    COMPREPLY=( $(compgen -W "${flags}" -- ${cur}) )
                    return 0
                    ;;
            esac
            ;;
        list)
            case "${prev}" in
                -h|--help)
                    return 0
                    ;;
                *)
                    local flags="-h --help"
                    COMPREPLY=( $(compgen -W "${flags}" -- ${cur}) )
                    return 0
                    ;;
            esac
            ;;
        clean)
            case "${prev}" in
                -f|--force|-h|--help)
                    return 0
                    ;;
                *)
                    local flags="-f --force -h --help"
                    COMPREPLY=( $(compgen -W "${flags}" -- ${cur}) )
                    return 0
                    ;;
            esac
            ;;
        open)
            case "${prev}" in
                -h|--help)
                    return 0
                    ;;
                *)
                    local flags="-h --help"
                    COMPREPLY=( $(compgen -W "${flags}" -- ${cur}) )
                    return 0
                    ;;
            esac
            ;;
    esac
}

# Register the completion function
complete -F _spt_completions spt
