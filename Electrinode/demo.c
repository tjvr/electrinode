
#include <stdio.h>

#include "node_main.h"
#include "v8_types.h"


void on_tick() {
  node_emit(node_string_from("C says BOO!"));
}

void on_message(NodeValue message) {
  char* string = node_get_string(message);
  printf("C received: %s\n", string);
}

int main(int argc, char* argv[]) {
    return node_main(argc, argv, on_tick, on_message);
}

