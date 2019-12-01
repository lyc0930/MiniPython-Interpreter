

enum Type
{
    None,      // 赋值语句、append()在python里没有输出
    Integer,   // 整型
    Real,      // 浮点型
    String,    // 字符和字符串
    List,      // 列表
    Variable,  // 变量
    ListSlice, // 列表切片
    ListItem   // 列表元素
};