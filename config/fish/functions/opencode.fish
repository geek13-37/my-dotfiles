function opencode --wraps='command opencode --standalone'
    if test (count $argv) -gt 0; and test "$argv[1]" = service
        command opencode $argv
    else
        command opencode --standalone $argv
    end
end
