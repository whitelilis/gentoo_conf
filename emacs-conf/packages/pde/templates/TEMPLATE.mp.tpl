verbatimtex
%&latex
\documentclass{article}
\usepackage{CJK}
\begin{CJK}{UTF8}{song}
\begin{document}
etex
%------------------------------
% put your Chinese character between 'btex' and 'etex'
% for example
% label.bot(btex 原点 etex, origin);
%------------------------------
filenametemplate "%j-%2c.mps";
beginfig(1);

  (>>>POINT<<<)

endfig;


%------------------------------
verbatimtex
\end{CJK}
\end{document}
etex
%------------------------------
end


