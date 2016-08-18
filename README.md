# GenstageExample3

This GenStage example is meant to illustrate the splitting of an output flow of
events - a list of integers - to more than one stage. This is accomplished by
using the PartitionDispatcher dispatcher and a "splitter" function that shunts
even integers to one partition and odd integers to another partition. For a more
detailed explanation, please see this blog [post](www.elixirfbp.com)

## To run:

1. cd genstage_example_3
2. mix deps.get
3. mix run lib/genstage_example_3.exs
