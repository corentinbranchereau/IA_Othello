% DISK DIFFERENCE HEURISTIC

:-writeln('Disk difference heuristic has loaded').

heuristic_disk_diff(Board, Value):- countDisk(Board, 0, 0, B, W), playerini(X, b), Value is (B-W) * X.