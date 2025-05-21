#include <stdlib.h>
#include <owi.h>

int main(void) {
    int s = owi_i32();
    if (s) {
      exit(0);
    }
    owi_assert(s);
}
