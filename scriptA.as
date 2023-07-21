
#include "sharedfunc.as"

void onInit(CRules@ this)
{
    print("start");
    peepeepoopoo@ func = @myPrint;

    if( func is null )
    {
        print("The function handle is null");
        return;
    }

    this.set("peepeepoopoo", @func);
}

void myPrint(string text)
{
    print(text, SColor(0xFFFF00DC));
}