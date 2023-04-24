#!/usr/bin/env python3

import ast
import os
import sys

class Flattener:

    def __init__(self, start):
        self.file_stack = []
        self.file_set = set()
        self.contracts_dirs = ['', 'contracts', 'node_modules']
        self.license_dirs = ['', '..']
        self.license_files = ['LICENSE', 'license', 'LICENSE.MD', 'LICENSE.md', 'license.md']
        self.project_root = start[0:start.rfind("contracts")]
        self.add_contract(os.path.abspath(start))

    def get_contract_path(self, fdir, contract_str):
        cp = os.path.abspath(os.path.join(fdir, contract_str))
        if os.path.exists(cp):
            return cp
        for contract_dir in self.contracts_dirs:
            cp = os.path.abspath(os.path.join(contract_dir, contract_str))
            if os.path.exists(cp):
                return cp
        for contract_dir in self.contracts_dirs:
            cp = os.path.abspath(os.path.join(self.project_root, contract_dir, contract_str))
            if os.path.exists(cp):
                return cp
        raise FileNotFoundError(contract_str)

    def get_license_path(self, contract_dir):
        for cd in self.contracts_dirs:
            dest_dir = contract_dir[0:contract_dir.rfind(cd)]
            for d in self.license_dirs:
                p = os.path.join(dest_dir, cd, d)
                for f in self.license_files:
                    ret = os.path.abspath(os.path.join(p, f))
                    if os.path.exists(ret):
                        return ret

    def add_contract(self, contract_path):
        self.file_stack.append((os.path.dirname(contract_path), open(contract_path, "r")))
        self.file_set.add(os.path.basename(contract_path))

    def run(self):
        (main_contract_dir, _) = self.file_stack[-1]
        lp = self.get_license_path(main_contract_dir)
        if lp is not None:
            print("/*")
            with open(lp, "r") as fh:
                print(fh.read()
                      .replace("/*", "\\/*")
                      .replace("*/", "*\\/"))
            print("*/")
            print()

        # This script uses a file handle to keep the position where it processing when it recurse :(
        while self.file_stack:
            # Files are iterators themselves
            (fdir, fh) = self.file_stack[-1]
            for line in fh:
                if line.startswith("import "):
                    include = line.strip().split()[-1].rstrip(';')
                    contract_str = ast.literal_eval(include)
                    contract = os.path.basename(contract_str)

                    if contract not in self.file_set:
                        contract_path = self.get_contract_path(fdir, contract_str)
                        self.add_contract(contract_path)
                    break
                # add only the original pragmas
                if line.startswith("pragma") and len(self.file_stack) != 1:
                    continue
                if line.startswith("// SPDX"):
                    continue
                print(line, end='')
            else:
                print()
                self.file_stack.pop()


if __name__ == '__main__':

    if len(sys.argv) != 2:
        print("Usage: python3 flattener.py FILEPATH", file=sys.stderr)
        exit(1)

    try:
        flattener = Flattener(sys.argv[1])
        flattener.run()
    except FileNotFoundError:
        print(f"Error: {repr(sys.argv[1])} file not found.", file=sys.stderr)
        exit(1)
