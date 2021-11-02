return{
    color=COLOR.cyan,
    env={
        drop=60,lock=60,
        wait=0,fall=50,
        garbageSpeed=30,
        highCam=false,
        seqData={1,2,3,4,5,6,7},
        eventSet='stack_e',
        bg='blockrain',bgm='there',
    },
    score=function(P)return{P.stat.row,P.stat.time}end,
    scoreDisp=function(D)return D[1].." Lines".."   "..STRING.time(D[2])end,
    comp=function(a,b)return a[1]>b[1]or a[1]==b[1]and a[2]<b[2]end,
    getRank=function(P)
        local L=P.stat.row
        return
        L>=200 and 5 or
        L>=175 and 4 or
        L>=150 and 3 or
        L>=120 and 2 or
        L>=90 and 1 or
        L>=30 and 0
    end,
}
