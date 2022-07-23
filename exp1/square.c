#include <stdio.h>

int main()
{
    int x = 5;
    int Q[8] = {0,0,0,0,0,1,0,1};//模拟8位寄存器，存储学号的二进制形式
    int res = 0;

    //原码一位乘过程
    x = x<<8;
    for(int i = 7;i >= 0;i--)
    {
        if(Q[i] == 1)
        {
            res = res + x;
        }
        res = res >> 1;
    }

    printf("%d\n",res);
}

