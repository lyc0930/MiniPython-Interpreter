

enum Type
{
    None,      // 赋值语句、列表方法等在python里没有输出
    Integer,   // 整型
    Real,      // 浮点型
    String,    // 字符和字符串
    List,      // 列表
    Variable,  // 变量
    ListSlice, // 列表切片
    ListItem   // 列表元素
};

// 模仿conio的getch
int getch(void)
{
    struct termios tm, tm_old;
    int fd = 0, c;

    if (tcgetattr(fd, &tm) < 0) // 保存当前终端设置
        return -1;

    tm_old = tm;
    cfmakeraw(&tm); // 更改设置内容为原始模式，该模式下所有的输入数据以字节为单位被处理

    if (tcsetattr(fd, TCSANOW, &tm) < 0) // 更改终端设置
        return -1;

    c = getchar();

    if (tcsetattr(fd, TCSANOW, &tm_old) < 0) // 还原终端设置
        return -1;

    return c;
}