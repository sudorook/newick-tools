/*
    Copyright (C) 2015 Tomas Flouri

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as
    published by the Free Software Foundation, either version 3 of the
    License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

    Contact: Tomas Flouri <Tomas.Flouri@h-its.org>,
    Heidelberg Institute for Theoretical Studies,
    Schloss-Wolfsbrunnenweg 35, D-69118 Heidelberg, Germany
*/
%{
#include "newick_tools.h"

extern int rtree_lex();
extern FILE * rtree_in;
extern void rtree_lex_destroy();

void rtree_destroy(rtree_t * root)
{
  if (!root) return;

  rtree_destroy(root->left);
  rtree_destroy(root->right);
  if (root->data)
    free(root->data);

  free(root->label);
  free(root);
}


static void rtree_error(rtree_t * tree, const char * s) 
{
}

%}


%union
{
  char * s;
  char * d;
  struct rtree_s * tree;
}

%error-verbose
%parse-param {struct rtree_s * tree}
%destructor { rtree_destroy($$); } subtree

%token OPAR
%token CPAR
%token COMMA
%token COLON SEMICOLON 
%token<s> STRING
%token<d> NUMBER
%type<s> label optional_label
%type<d> number optional_length
%type<tree> subtree
%start input
%%

input: OPAR subtree COMMA subtree CPAR optional_label optional_length SEMICOLON
{
  tree->left   = $2;
  tree->right  = $4;
  tree->label  = $6;
  tree->length = $7 ? atof($7) : 1;
  tree->leaves = $2->leaves + $4->leaves;
  tree->parent = NULL;
  tree->mark   = 0;
  free($7);

  tree->left->parent  = tree;
  tree->right->parent = tree;
};

subtree: OPAR subtree COMMA subtree CPAR optional_label optional_length
{
  $$ = (rtree_t *)calloc(1, sizeof(rtree_t));
  $$->left   = $2;
  $$->right  = $4;
  $$->label  = $6;
  $$->length = $7 ? atof($7) : 1;
  $$->leaves = $2->leaves + $4->leaves;
  $$->mark   = 0;
  free($7);

  $$->left->parent  = $$;
  $$->right->parent = $$;

}
       | label optional_length
{
  $$ = (rtree_t *)calloc(1, sizeof(rtree_t));
  $$->label  = $1;
  $$->length = $2 ? atof($2) : 1;
  $$->left   = NULL;
  $$->right  = NULL;
  $$->leaves = 1;
  $$->mark   = 0;
  free($2);
};

 
optional_label:  {$$ = NULL;} | label  {$$ = $1;};
optional_length: {$$ = NULL;} | COLON number {$$ = $2;};
label: STRING    {$$=$1;} | NUMBER {$$=$1;};
number: NUMBER   {$$=$1;};

%%

rtree_t * rtree_parse_newick(const char * filename)
{
  struct rtree_s * tree;

  tree = (rtree_t *)calloc(1, sizeof(rtree_t));

  rtree_in = fopen(filename, "r");
  if (!rtree_in)
  {
    rtree_destroy(tree);
    snprintf(errmsg, 200, "Unable to open file (%s)", filename);
    return NULL;
  }
  else if (rtree_parse(tree))
  {
    rtree_destroy(tree);
    tree = NULL;
    fclose(rtree_in);
    rtree_lex_destroy();
    return NULL;
  }
  
  if (rtree_in) fclose(rtree_in);

  rtree_lex_destroy();

  return tree;
}
