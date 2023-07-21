
#include "sharedfunc.as"

void onTick(CRules@ this)
{
    if(getGameTime() == 5)
    {
        peepeepoopoo@ func;
        this.get("peepeepoopoo", @func);

        if( func is null )
        {
            print("The function handle is null");
            return;
        }

        func("lol lmao");
    }
}