# Copyright (C) 2015 Tomas Flouri
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# Contact: Tomas Flouri <Tomas.Flouri@h-its.org>,
# Heidelberg Institute for Theoretical Studies,
# Schloss-Wolfsbrunnenweg 35, D-69118 Heidelberg, Germany

CC = gcc
CFLAGS = -g -Wall -D_GNU_SOURCE
LIBS = -lm

BISON = bison
FLEX = flex

PROG = newick-tools

SRCDIR=src

all: $(PROG)

OBJS=$(SRCDIR)/parse_ntree.o \
     $(SRCDIR)/parse_rtree.o \
     $(SRCDIR)/parse_utree.o \
     $(SRCDIR)/lex_ntree.o \
     $(SRCDIR)/lex_rtree.o \
     $(SRCDIR)/lex_utree.o \
     $(SRCDIR)/arch.o \
     $(SRCDIR)/attach.o \
     $(SRCDIR)/bd.o \
     $(SRCDIR)/create.o \
     $(SRCDIR)/dist.o \
     $(SRCDIR)/info.o \
     $(SRCDIR)/newick_tools.o \
     $(SRCDIR)/ntree.o \
     $(SRCDIR)/labels.o \
     $(SRCDIR)/lca_utree.o \
     $(SRCDIR)/lca_tips.o \
     $(SRCDIR)/prune.o \
     $(SRCDIR)/rtree.o \
     $(SRCDIR)/subtree.o \
     $(SRCDIR)/svg.o \
     $(SRCDIR)/stats.o \
     $(SRCDIR)/util.o \
     $(SRCDIR)/utree.o \
     $(SRCDIR)/utree_bf.o

EXTRA=$(SRCDIR)/lex_ntree.h \
      $(SRCDIR)/lex_rtree.h \
      $(SRCDIR)/lex_utree.h \
      $(SRCDIR)/parse_ntree.h \
      $(SRCDIR)/parse_rtree.h \
      $(SRCDIR)/parse_utree.h \

$(PROG): $(OBJS)
	$(CC) $(CFLAGS) $+ -o $@ $(LIBS)

%.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

parse_%.c: parse_%.y
	$(BISON) -p $(patsubst $(SRCDIR)/%,%,$*)_ -d -o $@ $<

%.c: %.l
	$(FLEX) -o $@ $<

clean:
	rm -f $(OBJS) 
	rm -f gmon.out 
	rm -f $(PROG) 
	rm -f $(EXTRA)
