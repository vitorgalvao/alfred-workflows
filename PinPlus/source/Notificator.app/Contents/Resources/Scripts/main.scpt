JsOsaDAS1.001.00bplist00�Vscripto� / /   B u i l d   a r g v / a r g c   i n   a   w a y   t h a t   c a n   b e   u s e d   f r o m   t h e   a p p l e t   i n s i d e   t h e   a p p   b u n d l e 
 O b j C . i m p o r t ( ' F o u n d a t i o n ' ) 
 c o n s t   a r g s   =   $ . N S P r o c e s s I n f o . p r o c e s s I n f o . a r g u m e n t s 
 c o n s t   a r g v   =   [ ] 
 c o n s t   a r g c   =   a r g s . c o u n t 
 f o r   ( l e t   i   =   0 ;   i   <   a r g c ;   i + + )   {   a r g v . p u s h ( O b j C . u n w r a p ( a r g s . o b j e c t A t I n d e x ( i ) ) )   } 
 d e l e t e   a r g s 
 
 / /   N o t i f i c a t i o n   s c r i p t 
 c o n s t   a p p   =   A p p l i c a t i o n . c u r r e n t A p p l i c a t i o n ( ) 
 a p p . i n c l u d e S t a n d a r d A d d i t i o n s   =   t r u e 
 
 i f   ( a r g v . l e n g t h   <   2 )     {   / /   W e   u s e   ' 2 '   s i n c e   t h e   s c r i p t   w i l l   a l w a y s   s e e   a t   l e a s t   o n e   a r g u m e n t :   t h e   a p p l e t   i t s e l f 
     a r g v [ 1 ]   =   ' Y o u   c a n n o t   r u n   i t   b y   d o u b l e - c l i c k i n g   t h e   a p p   b u n d l e .   O p e n i n g   u s a g e   i n s t r u c t i o n s & ' 
     a r g v [ 2 ]   =   ' N o t i f i c a t o r   i s   a   c o m m a n d - l i n e   a p p ' 
     a r g v [ 4 ]   =   ' F u n k ' 
 
     a p p . o p e n L o c a t i o n ( ' h t t p s : / / g i t h u b . c o m / v i t o r g a l v a o / n o t i f i c a t o r # u s a g e ' ) 
 } 
 
 c o n s t   m e s s a g e   =   a r g v [ 1 ] 
 c o n s t   t i t l e   =   a r g v [ 2 ] 
 c o n s t   s u b t i t l e   =   a r g v [ 3 ] 
 c o n s t   s o u n d   =   a r g v [ 4 ] 
 
 c o n s t   o p t i o n s   =   { } 
 i f   ( t i t l e )   o p t i o n s . w i t h T i t l e   =   t i t l e 
 i f   ( s u b t i t l e )   o p t i o n s . s u b t i t l e   =   s u b t i t l e 
 i f   ( s o u n d )   o p t i o n s . s o u n d N a m e   =   s o u n d 
 
 a p p . d i s p l a y N o t i f i c a t i o n ( m e s s a g e ,   o p t i o n s ) 
                              jscr  ��ޭ