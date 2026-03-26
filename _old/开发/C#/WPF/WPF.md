---
layout: post
title: WPF
subtitle:
date: 2021-06-30 17:32:28
categories: [WPF]
tags: [WPF, WPF]
---

# 1 attribute="value"

因Xaml 的语法限制 - 一个类能使用Xaml 的语法进行申明，并允许属性与Xaml 标签的 attribute 相互映射，需要为这些属性准备适当的***转换时机*** - value 为字符串，复杂度有限，Xaml的使用者需要手写一个格式负责的串已满足赋值要求

解决方案：
问题1：使用 `TypeConverter`的派生类 与 `TypeConverterAttribute`，
问题2：使用 `属性元素`（Property Element）- 能使用 attribute='value' 的就不要使用属性元素 - 充分利用默认值去除多余的属性 StartPoint="0,0" EndPort="1,1" 类似的默认值 - 充分利用Xaml 的简写

```
<Rectangle x:Name="Rectangle1">
    <Rectangle.Fill>
        //非空标签均有自己的内容（可以是很复杂的）
    </Rectangle.File>
</Rectangle>
```

```C#
[TypeConverter(typeof(StringToHumanTypeConverter))]
public class Human{
    public string Name{get;set;}
    public Human  Child{get;set;}
}
private void button_click(object sender,RoutedEventArgs e)
{
    Human h=(Human)this.FindResource('human');//运行异常，Child 不存在，Xaml Child 为ABC Human 中的Child为 Human
    MessageBox.Show(h.Child.Name);
}

public class StringToHumanTypeConverter:TypeConverter{
    public override object ConvertForm(ITypeDescriptorContext context,CultureInfo culture,object value){
        if(value is string){
            Human h=new Human()
            h.Name=value as string;
            return h;
        }
        return base.ConvertForm(context,culture,value);
    }
}
```

```xmal
<window.Resources>
    <local:Human x:Key="human" Child="ABC"/>
</window.Resources>
```

# 2. 扩展标签 attribute="{}"

内容有‘{}’ 括起来，由Xaml 编译器做出解析 生产相应的对象

```
<TextBox Margin="5" Text="{Binding ElementName=slider1,Path=Value,Mode=OneWay}"/>
与
<TextBox Margin=5>
    <TextBox.Text>
        <Binding ElementName="slider1" Path="Value" Mode="OneWay"/>
    </TextBox.Text>
```

尽管标记扩展语法简洁方便，但并不是所有对象都能使用编辑扩展的语法来书写，只有`MarkupExtension` 类的派生类才能使用
直接派生类：

```
System.Windows.ColorConvertedBitmapExtension
System.Windows.Data.BindingBase
System.Windows.Data.RelativeSource
System.Windows.DynamicResourceExtension
System.Windows.Markup.ArrayExtension

System.Windows.Markup.NullExtension
System.Windows.Markup.StaticExtension
System.Windows.Markup.ResourceKey
System.Windows.Markup.StaticResourceExtension
System.Windows.Markup.ThemeDictionaryExtension
```

# 基础

- 所有的Xaml 标签都是 .Net 对象
- Xaml 标签可以使用x:class指定将由xaml解析生产的类与那个类合并 ，代码后置就是有设计师创建Xaml UI<-----事件性Attribute------>程序员C# 类 ，这样UI与逻辑代码分离
- 标签 `x:Code ` 可以把本应该在后再代码里的C#代码搬至 Xaml 文件中来

```
<x:Code>
<![CDATA[
    private void button_click(object sender,RoutedEventArgs e){}
]]>
</x:Code>
```

- x:ClassModifier 生成的类的访问级别，需要与后台代码的访问级别一致
- Xaml 对象声明语言只负责声明对象 不负责为这些对象声明引用，如需为对象准备一个引用变量可 使用 `x:Name`,当元素基友Name属性是， 使用Name 与使用X:Name 一样，而对于没有Name 对象，为了在Xaml声明是也创建引用变量以便在C#代码中访问，只能使用x:Name
- x:FieldModifier 元素的访问级别（默认internal）
- x:Shared ,同一对象 还是对象的多个副本， 与x:Key 一起使用`x:Share="true"`得到的是同一对象(默认)

# ItemsControl族

- 内容属性为Items 或ItemsSource
- 有自己的条目容器（Item Container），自动使用条目容器对内容进行包装，控件得到集合后使用条目容器把集合中的条目逐个包装当作内容

```
 VisualTreeHelper.GetParent(controller) ;在可视化树上导航元素
// ListBoxItem 为 ListBox的 条目容器（Item Container）
// DisplayMemberPath 告诉ListBox 显示每条数据的那个属性
//SelectValuePath 与 SelectedValue属性配合使用 ，1.调用SelecedValue ->listBox 找到选中的Item数据对象-->SelectedValuePath 的值当作数据对象的属性名称，取出改属性值
```
