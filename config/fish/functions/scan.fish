function scan --wraps='clamscan -r' --description 'alias scan=clamscan -r'
    clamscan -r $argv
end
