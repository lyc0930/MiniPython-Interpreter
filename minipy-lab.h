

enum Type
{
    Integer,
    Real,
    String,
    List,
    Variable,
    None,      // 赋值语句、append()在python里没有输出
    ListSlice, // 列表切片
    ListItem   // 列表元素
};