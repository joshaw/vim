finish

if exists("g:load_black")
   finish
endif

python3 << endpython3
import vim
import black

def Black():
  fast = True
  mode = black.FileMode(
    line_length=88,
    string_normalization=True,
    is_pyi=vim.current.buffer.name.endswith('.pyi'),
  )
  buffer_str = '\n'.join(vim.current.buffer) + '\n'
  try:
    new_buffer_str = black.format_file_contents(buffer_str, fast=fast, mode=mode)
  except black.NothingChanged:
    print(f'Already well formatted.')
  except Exception as exc:
    print(exc)
  else:
    current_buffer = vim.current.window.buffer
    cursors = []
    for i, tabpage in enumerate(vim.tabpages):
      if tabpage.valid:
        for j, window in enumerate(tabpage.windows):
          if window.valid and window.buffer == current_buffer:
            cursors.append((i, j, window.cursor))
    vim.current.buffer[:] = new_buffer_str.split('\n')[:-1]
    for i, j, cursor in cursors:
      window = vim.tabpages[i].windows[j]
      try:
        window.cursor = cursor
      except vim.error:
        window.cursor = (len(window.buffer), 0)
    print(f'Reformatted.')

endpython3

command! Black :py3 Black()
