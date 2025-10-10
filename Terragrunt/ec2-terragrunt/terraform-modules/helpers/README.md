# helpers

This directory contains terraform modules that do not provision resources directly, but assist in
reshaping data structures for that purpose in other calling modules. Typically, they will contain
only inputs, locals and outputs, but occassionally query remote data sources. Creating AWS resources
in a helper module is strongly discouraged.
