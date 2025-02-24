import 'package:flutter/material.dart';

class AmenitiesUI extends StatefulWidget
{
  String Type;
  int startValue;
  Function decreaseVal;
  Function increaseVal;

  AmenitiesUI({super.key,required this.Type , required this.startValue , required this.decreaseVal , required this.increaseVal});

  @override
  State<AmenitiesUI> createState()=> _AmenitiesUIState();
}
class _AmenitiesUIState extends State<AmenitiesUI>
{
  int? _valueDigit;

  @override
  void initState()
  {
    super.initState();

    _valueDigit = widget.startValue;
  }

  @override
  Widget build(BuildContext context)
  {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          widget.Type,
          style: const TextStyle(
            fontSize: 18.0,
          ),
        ),
        Row(
          children: <Widget>[
            IconButton(
                onPressed: (){
                  widget.decreaseVal();

                  _valueDigit = _valueDigit!- 1;
                  if(_valueDigit!<0)
                    {
                      _valueDigit=0;
                    }
                  setState(() {

                  });
                },
              icon: const Icon(Icons.remove),
            ),
            Text(
              _valueDigit.toString(),
              style: const TextStyle(
                fontSize: 20.0,
              ),
            ),
            IconButton(
              onPressed: (){
                widget.increaseVal();

                _valueDigit = _valueDigit!+ 1;

                setState(() {

                });
              },
              icon: const Icon(Icons.add),
            ),
          ],
        )
      ],
    );
  }

}