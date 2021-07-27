--app.command.FitScreen()

--app.command.GotoNextTab()

--app.command.TogglePreview()

--app.command.FullscreenPreview()

local dlg = Dialog {
    title = "test",
}

    dlg
        :combobox
    {
        id=test,
        label=test,
        option="three",
        options={"one", "two", "three"},        
        onchange=function()
            print("foo")
        end
    }


        :show {wait=false}
    
