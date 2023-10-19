" define function for loading dotenv variables
function! s:env(var) abort
  return exists('*DotenvGet') ? DotenvGet(a:var) : eval('$'.a:var)
endfunction

" load .env file from home dir
Dotenv ~

let g:codegpt_openai_api_key = s:env('CODEGPT_OPENAI_API_KEY')
