import os


def remove_all_files(my_dir):
    path = os.path.join(os.getcwd(), my_dir)
    for f in os.listdir(path):
        if not f.startswith('.'):
            os.remove(os.path.join(path, f))


if __name__ == '__main__':
    pass
